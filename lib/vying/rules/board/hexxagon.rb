# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Hexxagon is Ataxx played on a hex board.
#
# For detailed rules, etc:  http://vying.org/games/hexxagon

Rules.create( "Hexxagon" ) do
  name    "Hexxagon"
  version "0.5.0"

  players :red, :blue, :white
  option :number_of_players, :default => 2, :values => [2, 3]

  score_determines_outcome
  random

  cache :moves

  position do
    attr_reader :board, :block_pattern

    def init
      @board = Board.hexagon( 5 )

      if options[:number_of_players] == 2
        @board[:a1, :i5, :e9] = :red
        @board[:e1, :a5, :i9] = :blue
      else
        @board[:a5, :i5] = :red
        @board[:a1, :i9] = :blue
        @board[:e1, :e9] = :white
      end

      @block_pattern = set_rand_blocks
    end

    def moves
      return [] if final?

      found = []

      board.occupied( turn ).each do |c|
        # Adjacent moves
        board.coords.ring( c, 1 ).each do |c1|
          found << "#{c}#{c1}" if board[c1].nil?
        end

        # Jump moves
        board.coords.ring( c, 2 ).each do |c2|
          found << "#{c}#{c2}" if board[c2].nil?
        end
      end

      found
    end

    def apply!( move )
      coords, p = move.to_coords, turn

      if board.coords.ring( coords.first, 1 ).include?( coords.last )
        board[coords.last] = turn
      else
        board.move( coords.first, coords.last )
      end

      board.coords.neighbors( coords.last ).each do |c|
        unless board[c].nil? || board[c] == turn || board[c] == :x
          board[c] = turn
        end
      end

      rotate_turn

      (options[:number_of_players] - 1).times do
        if moves.empty?
          rotate_turn
          clear_cache
        end
      end

      self
    end

    def final?
      return true if board.unoccupied.empty?

      np = @options[:number_of_players]
      zero_count = players.select { |p| board.count( p ) == 0 }.length

      np - 1 == zero_count
    end

    def score( player )
      board.count( player )
    end

    def set_blocks( p )
      p.scan( /./m ) do |c|
        board[*rules.block_coords[c]] = :x
      end
      p
    end

    def set_rand_blocks
      set_blocks( rules.blocks[rand( rules.blocks.length )] )
    end

    def clear_blocks
      board[*board.occupied( :x )] = nil
      @block_pattern = ""
    end
  end

  blocks   %w( x


               1 2 3 4 5


               1x 2x 3x 4x 5x


               12 13 23 14 24 34 15 25 35 45 a b c d e f g h i j k


               12x 13x 23x 14x 24x 34x 15x 25x 35x 45x 
               ax bx cx dx ex fx gx hx ix jx kx


               123 124 134 234 125 135 235 145 245 345 
               1a 2a 3a 4a 5a 1b 2b 3b 4b 5b 1c 2c 3c 4c 5c 
               1d 2d 3d 4d 5d 1e 2e 3e 4e 5e 1f 2f 3f 4f 5f 
               1g 2g 3g 4g 5g 1h 2h 3h 4h 5h 1i 2i 3i 4i 5i 
               1j 2j 3j 4j 5j 1k 2k 3k 4k 5k


               123x 124x 134x 234x 125x 135x 235x 145x 245x 345x 
               1ax 2ax 3ax 4ax 5ax 1bx 2bx 3bx 4bx 5bx 
               1cx 2cx 3cx 4cx 5cx 1dx 2dx 3dx 4dx 5dx 
               1ex 2ex 3ex 4ex 5ex 1fx 2fx 3fx 4fx 5fx 
               1gx 2gx 3gx 4gx 5gx 1hx 2hx 3hx 4hx 5hx 
               1ix 2ix 3ix 4ix 5ix 1jx 2jx 3jx 4jx 5jx 
               1kx 2kx 3kx 4kx 5kx


               1234 1235 1245 1345 2345 
               12a 13a 23a 14a 24a 34a 15a 25a 35a 45a 12b 13b 23b
               14b 24b 34b 15b 25b 35b 45b ab 12c 13c 23c 14c 24c 34c 
               15c 25c 35c 45c ac bc 12d 13d 23d 14d 24d 34d 15d 25d 35d 45d 
               ad bd cd 12e 13e 23e 14e 24e 34e 15e 25e 35e 45e ae be ce de 
               12f 13f 23f 14f 24f 34f 15f 25f 35f 45f af bf cf df ef 
               12g 13g 23g 14g 24g 34g 15g 25g 35g 45g ag bg cg dg eg fg 
               12h 13h 23h 14h 24h 34h 15h 25h 35h 45h ah bh ch dh eh fh gh 
               12i 13i 23i 14i 24i 34i 15i 25i 35i 45i 
               ai bi ci di ei fi gi hi 
               12j 13j 23j 14j 24j 34j 15j 25j 35j 45j 
               aj bj cj dj ej fj gj hj ij 
               12k 13k 23k 14k 24k 34k 15k 25k 35k 45k 
               ak bk ck dk ek fk gk hk ik jk


               1234x 1235x 1245x 1345x 2345x 
               12ax 13ax 23ax 14ax 24ax 34ax 15ax 25ax 35ax 45ax 
               12bx 13bx 23bx 14bx 24bx 34bx 15bx 25bx 35bx 45bx 
               abx 12cx 13cx 23cx 14cx 24cx 34cx 15cx 25cx 35cx 45cx 
               acx bcx 12dx 13dx 23dx 14dx 24dx 34dx 15dx 25dx 35dx 45dx 
               adx bdx cdx 12ex 13ex 23ex 14ex 24ex 34ex 15ex 25ex 35ex 45ex 
               aex bex cex dex 12fx 13fx 23fx 
               14fx 24fx 34fx 15fx 25fx 35fx 45fx afx bfx cfx dfx efx 
               12gx 13gx 23gx 14gx 24gx 34gx 15gx 25gx 35gx 45gx 
               agx bgx cgx dgx egx fgx 12hx 13hx 23hx 14hx 24hx 34hx 15hx 25hx 
               35hx 45hx ahx bhx chx dhx ehx fhx ghx 12ix 13ix 23ix 14ix 
               24ix 34ix 15ix 25ix 35ix 45ix aix bix cix dix eix fix gix hix 
               12jx 13jx 23jx 14jx 24jx 34jx 15jx 25jx 35jx 45jx 
               ajx bjx cjx djx ejx fjx gjx hjx ijx 
               12kx 13kx 23kx 14kx 24kx 34kx 15kx 25kx 35kx 45kx 
               akx bkx ckx dkx ekx fkx gkx hkx ikx jkx


               12345 123a 124a 134a 234a 125a 135a 235a 145a 245a 345a 123b 
               124b 134b 234b 125b 135b 235b 145b 245b 345b 
               1ab 2ab 3ab 4ab 5ab 123c 124c 134c 234c 125c 135c 235c 145c 
               245c 345c 1ac 2ac 3ac 4ac 5ac 1bc 2bc 3bc 4bc 5bc 
               123d 124d 134d 234d 125d 135d 235d 145d 245d 345d 
               1ad 2ad 3ad 4ad 5ad 1bd 2bd 3bd 4bd 5bd 1cd 2cd 3cd 4cd 5cd 
               123e 124e 134e 234e 125e 135e 235e 145e 245e 345e 
               1ae 2ae 3ae 4ae 5ae 1be 2be 3be 4be 5be 1ce 2ce 3ce 4ce 5ce 1de 
               2de 3de 4de 5de 123f 124f 134f 234f 125f 135f 235f 145f 245f 
               345f 1af 2af 3af 4af 5af 1bf 2bf 3bf 4bf 5bf 1cf 2cf 3cf 4cf 
               5cf 1df 2df 3df 4df 5df 1ef 2ef 3ef 4ef 5ef 123g 124g 134g 234g 
               125g 135g 235g 145g 245g 345g 1ag 2ag 3ag 4ag 5ag 1bg 2bg 3bg 
               4bg 5bg 1cg 2cg 3cg 4cg 5cg 1dg 2dg 3dg 4dg 5dg 1eg 2eg 3eg 4eg
               5eg 1fg 2fg 3fg 4fg 5fg 123h 124h 134h 234h 125h 135h 235h 145h
               245h 345h 1ah 2ah 3ah 4ah 5ah 1bh 2bh 3bh 4bh 5bh 1ch 2ch 3ch 
               4ch 5ch 1dh 2dh 3dh 4dh 5dh 1eh 2eh 3eh 4eh 5eh 1fh 2fh 3fh 4fh 
               5fh 1gh 2gh 3gh 4gh 5gh 123i 124i 134i 234i 125i 135i 235i 145i 
               245i 345i 1ai 2ai 3ai 4ai 5ai 1bi 2bi 3bi 4bi 5bi 1ci 2ci 3ci 
               4ci 5ci 1di 2di 3di 4di 5di 1ei 2ei 3ei 4ei 5ei 1fi 2fi 3fi 4fi
               5fi 1gi 2gi 3gi 4gi 5gi 1hi 2hi 3hi 4hi 5hi 123j 124j 134j 234j 
               125j 135j 235j 145j 245j 345j 1aj 2aj 3aj 4aj 5aj 1bj 2bj 3bj 
               4bj 5bj 1cj 2cj 3cj 4cj 5cj 1dj 2dj 3dj 4dj 5dj 1ej 2ej 3ej 4ej
               5ej 1fj 2fj 3fj 4fj 5fj 1gj 2gj 3gj 4gj 5gj 1hj 2hj 3hj 4hj 5hj 
               1ij 2ij 3ij 4ij 5ij 123k 124k 134k 234k 125k 135k 235k 145k 
               245k 345k 1ak 2ak 3ak 4ak 5ak 1bk 2bk 3bk 4bk 5bk 1ck 2ck 3ck 
               4ck 5ck 1dk 2dk 3dk 4dk 5dk 1ek 2ek 3ek 4ek 5ek 1fk 2fk 3fk 4fk
               5fk 1gk 2gk 3gk 4gk 5gk 1hk 2hk 3hk 4hk 5hk 1ik 2ik 3ik 4ik 5ik
               1jk 2jk 3jk 4jk 5jk 


               12345x 123ax 124ax 134ax 234ax 125ax 135ax 235ax 145ax 245ax 
               345ax 123bx 124bx 134bx 234bx 125bx 135bx 235bx 145bx 245bx 
               345bx 1abx 2abx 3abx 4abx 5abx 123cx 124cx 134cx 234cx 125cx 
               135cx 235cx 145cx 245cx 345cx 1acx 2acx 3acx 4acx 5acx 1bcx 
               2bcx 3bcx 4bcx 5bcx 123dx 124dx 134dx 234dx 125dx 135dx 235dx 
               145dx 245dx 345dx 1adx 2adx 3adx 4adx 5adx 1bdx 2bdx 3bdx 4bdx 
               5bdx 1cdx 2cdx 3cdx 4cdx 5cdx 123ex 124ex 134ex 234ex 125ex 
               135ex 235ex 145ex 245ex 345ex 1aex 2aex 3aex 4aex 5aex 1bex 
               2bex 3bex 4bex 5bex 1cex 2cex 3cex 4cex 5cex 1dex 2dex 3dex 
               4dex 5dex 123fx 124fx 134fx 234fx 125fx 135fx 235fx 145fx 245fx
               345fx 1afx 2afx 3afx 4afx 5afx 1bfx 2bfx 3bfx 4bfx 5bfx 1cfx 
               2cfx 3cfx 4cfx 5cfx 1dfx 2dfx 3dfx 4dfx 5dfx 1efx 2efx 3efx 
               4efx 5efx 123gx 124gx 134gx 234gx 125gx 135gx 235gx 145gx 245gx 
               345gx 1agx 2agx 3agx 4agx 5agx 1bgx 2bgx 3bgx 4bgx 5bgx 1cgx 
               2cgx 3cgx 4cgx 5cgx 1dgx 2dgx 3dgx 4dgx 5dgx 1egx 2egx 3egx 
               4egx 5egx 1fgx 2fgx 3fgx 4fgx 5fgx 123hx 124hx 134hx 234hx 
               125hx 135hx 235hx 145hx 245hx 345hx 1ahx 2ahx 3ahx 4ahx 5ahx 
               1bhx 2bhx 3bhx 4bhx 5bhx 1chx 2chx 3chx 4chx 5chx 1dhx 2dhx 
               3dhx 4dhx 5dhx 1ehx 2ehx 3ehx 4ehx 5ehx 1fhx 2fhx 3fhx 4fhx 
               5fhx 1ghx 2ghx 3ghx 4ghx 5ghx 123ix 124ix 134ix 234ix 125ix 
               135ix 235ix 145ix 245ix 345ix 1aix 2aix 3aix 4aix 5aix 1bix 
               2bix 3bix 4bix 5bix 1cix 2cix 3cix 4cix 5cix 1dix 2dix 3dix 
               4dix 5dix 1eix 2eix 3eix 4eix 5eix 1fix 2fix 3fix 4fix 5fix 
               1gix 2gix 3gix 4gix 5gix 1hix 2hix 3hix 4hix 5hix 123jx 124jx 
               134jx 234jx 125jx 135jx 235jx 145jx 245jx 345jx 1ajx 2ajx 
               3ajx 4ajx 5ajx 1bjx 2bjx 3bjx 4bjx 5bjx 1cjx 2cjx 3cjx 4cjx 
               5cjx 1djx 2djx 3djx 4djx 5djx 1ejx 2ejx 3ejx 4ejx 5ejx 1fjx 
               2fjx 3fjx 4fjx 5fjx 1gjx 2gjx 3gjx 4gjx 5gjx 1hjx 2hjx 3hjx
               4hjx 5hjx 1ijx 2ijx 3ijx 4ijx 5ijx 123kx 124kx 134kx 234kx 
               125kx 135kx 235kx 145kx 245kx 345kx 1akx 2akx 3akx 4akx 5akx 
               1bkx 2bkx 3bkx 4bkx 5bkx 1ckx 2ckx 3ckx 4ckx 5ckx 1dkx 2dkx 
               3dkx 4dkx 5dkx 1ekx 2ekx 3ekx 4ekx 5ekx 1fkx 2fkx 3fkx 4fkx 
               5fkx 1gkx 2gkx 3gkx 4gkx 5gkx 1hkx 2hkx 3hkx 4hkx 5hkx 1ikx
               2ikx 3ikx 4ikx 5ikx 1jkx 2jkx 3jkx 4jkx 5jkx

               1234a 1235a 1245a 1345a 2345a 1234b 1235b 1245b 1345b 2345b 
               12ab 13ab 23ab 14ab 24ab 34ab 15ab 25ab 35ab 45ab 1234c 1235c 
               1245c 1345c 2345c 12ac 13ac 23ac 14ac 24ac 34ac 15ac 25ac 35ac 
               45ac 12bc 13bc 23bc 14bc 24bc 34bc 15bc 25bc 35bc 45bc abc 
               1234d 1235d 1245d 1345d 2345d 12ad 13ad 23ad 14ad 24ad 34ad 
               15ad 25ad 35ad 45ad 12bd 13bd 23bd 14bd 24bd 34bd 15bd 25bd 
               35bd 45bd abd 12cd 13cd 23cd 14cd 24cd 34cd 15cd 25cd 35cd 45cd
               acd bcd 1234e 1235e 1245e 1345e 2345e 12ae 13ae 23ae 14ae 24ae 
               34ae 15ae 25ae 35ae 45ae 12be 13be 23be 14be 24be 34be 15be 25be
               35be 45be abe 12ce 13ce 23ce 14ce 24ce 34ce 15ce 25ce 35ce 45ce 
               ace bce 12de 13de 23de 14de 24de 34de 15de 25de 35de 45de ade 
               bde cde 1234f 1235f 1245f 1345f 2345f 12af 13af 23af 14af 24af 
               34af 15af 25af 35af 45af 12bf 13bf 23bf 14bf 24bf 34bf 15bf 
               25bf 35bf 45bf abf 12cf 13cf 23cf 14cf 24cf 34cf 15cf 25cf 35cf
               45cf acf bcf 12df 13df 23df 14df 24df 34df 15df 25df 35df 45df 
               adf bdf cdf 12ef 13ef 23ef 14ef 24ef 34ef 15ef 25ef 35ef 45ef 
               aef bef cef def 1234g 1235g 1245g 1345g 2345g 12ag 13ag 23ag 
               14ag 24ag 34ag 15ag 25ag 35ag 45ag 12bg 13bg 23bg 14bg 24bg 
               34bg 15bg 25bg 35bg 45bg abg 12cg 13cg 23cg 14cg 24cg 34cg 15cg 
               25cg 35cg 45cg acg bcg 12dg 13dg 23dg 14dg 24dg 34dg 15dg 25dg 
               35dg 45dg adg bdg cdg 12eg 13eg 23eg 14eg 24eg 34eg 15eg 25eg 
               35eg 45eg aeg beg ceg deg 12fg 13fg 23fg 14fg 24fg 34fg 15fg 
               25fg 35fg 45fg afg bfg cfg dfg efg 1234h 1235h 1245h 1345h 
               2345h 12ah 13ah 23ah 14ah 24ah 34ah 15ah 25ah 35ah 45ah 12bh 
               13bh 23bh 14bh 24bh 34bh 15bh 25bh 35bh 45bh abh 12ch 13ch 23ch 
               14ch 24ch 34ch 15ch 25ch 35ch 45ch ach bch 12dh 13dh 23dh 14dh 
               24dh 34dh 15dh 25dh 35dh 45dh adh bdh cdh 12eh 13eh 23eh 14eh 
               24eh 34eh 15eh 25eh 35eh 45eh aeh beh ceh deh 12fh 13fh 23fh 
               14fh 24fh 34fh 15fh 25fh 35fh 45fh afh bfh cfh dfh efh 12gh 
               13gh 23gh 14gh 24gh 34gh 15gh 25gh 35gh 45gh agh bgh cgh dgh 
               egh fgh 1234i 1235i 1245i 1345i 2345i 12ai 13ai 23ai 14ai 24ai
               34ai 15ai 25ai 35ai 45ai 12bi 13bi 23bi 14bi 24bi 34bi 15bi 
               25bi 35bi 45bi abi 12ci 13ci 23ci 14ci 24ci 34ci 15ci 25ci 35ci 
               45ci aci bci 12di 13di 23di 14di 24di 34di 15di 25di 35di 45di 
               adi bdi cdi 12ei 13ei 23ei 14ei 24ei 34ei 15ei 25ei 35ei 45ei 
               aei bei cei dei 12fi 13fi 23fi 14fi 24fi 34fi 15fi 25fi 35fi 
               45fi afi bfi cfi dfi efi 12gi 13gi 23gi 14gi 24gi 34gi 15gi 
               25gi 35gi 45gi agi bgi cgi dgi egi fgi 12hi 13hi 23hi 14hi 24hi
               34hi 15hi 25hi 35hi 45hi ahi bhi chi dhi ehi fhi ghi 1234j 
               1235j 1245j 1345j 2345j 12aj 13aj 23aj 14aj 24aj 34aj 15aj 
               25aj 35aj 45aj 12bj 13bj 23bj 14bj 24bj 34bj 15bj 25bj 35bj 
               45bj abj 12cj 13cj 23cj 14cj 24cj 34cj 15cj 25cj 35cj 45cj 
               acj bcj 12dj 13dj 23dj 14dj 24dj 34dj 15dj 25dj 35dj 45dj adj 
               bdj cdj 12ej 13ej 23ej 14ej 24ej 34ej 15ej 25ej 35ej 45ej aej 
               bej cej dej 12fj 13fj 23fj 14fj 24fj 34fj 15fj 25fj 35fj 45fj 
               afj bfj cfj dfj efj 12gj 13gj 23gj 14gj 24gj 34gj 15gj 25gj 
               35gj 45gj agj bgj cgj dgj egj fgj 12hj 13hj 23hj 14hj 24hj 34hj 
               15hj 25hj 35hj 45hj ahj bhj chj dhj ehj fhj ghj 12ij 13ij 23ij 
               14ij 24ij 34ij 15ij 25ij 35ij 45ij aij bij cij dij eij fij gij
               hij 1234k 1235k 1245k 1345k 2345k 12ak 13ak 23ak 14ak 24ak 34ak 
               15ak 25ak 35ak 45ak 12bk 13bk 23bk 14bk 24bk 34bk 15bk 25bk 
               35bk 45bk abk 12ck 13ck 23ck 14ck 24ck 34ck 15ck 25ck 35ck 45ck 
               ack bck 12dk 13dk 23dk 14dk 24dk 34dk 15dk 25dk 35dk 45dk adk 
               bdk cdk 12ek 13ek 23ek 14ek 24ek 34ek 15ek 25ek 35ek 45ek aek 
               bek cek dek 12fk 13fk 23fk 14fk 24fk 34fk 15fk 25fk 35fk 45fk 
               afk bfk cfk dfk efk 12gk 13gk 23gk 14gk 24gk 34gk 15gk 25gk 
               35gk 45gk agk bgk cgk dgk egk fgk 12hk 13hk 23hk 14hk 24hk 34hk
               15hk 25hk 35hk 45hk ahk bhk chk dhk ehk fhk ghk 12ik 13ik 23ik 
               14ik 24ik 34ik 15ik 25ik 35ik 45ik aik bik cik dik eik fik gik 
               hik 12jk 13jk 23jk 14jk 24jk 34jk 15jk 25jk 35jk 45jk ajk bjk 
               cjk djk ejk fjk gjk hjk ijk 


               1234ax 1235ax 1245ax 1345ax 2345ax 1234bx 1235bx 1245bx 1345bx
               2345bx 12abx 13abx 23abx 14abx 24abx 34abx 15abx 25abx
               35abx 45abx 1234cx 1235cx 1245cx 1345cx 2345cx 12acx 
               13acx 23acx 14acx 24acx 34acx 15acx 25acx 35acx 45acx 
               12bcx 13bcx 23bcx 14bcx 24bcx 34bcx 15bcx 25bcx 35bcx
               45bcx abcx 1234dx 1235dx 1245dx 1345dx 2345dx 12adx 13adx 
               23adx 14adx 24adx 34adx 15adx 25adx 35adx 45adx 12bdx 13bdx 
               23bdx 14bdx 24bdx 34bdx 15bdx 25bdx 35bdx 45bdx abdx 12cdx 
               13cdx 23cdx 14cdx 24cdx 34cdx 15cdx 25cdx 35cdx 45cdx acdx 
               bcdx 1234ex 1235ex 1245ex 1345ex 2345ex 12aex 13aex 23aex 
               14aex 24aex 34aex 15aex 25aex 35aex 45aex 12bex 13bex 23bex 
               14bex 24bex 34bex 15bex 25bex 35bex 45bex abex 12cex 13cex 
               23cex 14cex 24cex 34cex 15cex 25cex 35cex 45cex acex bcex 
               12dex 13dex 23dex 14dex 24dex 34dex 15dex 25dex 35dex 
               45dex adex bdex cdex 1234fx 1235fx 1245fx 1345fx 2345fx 
               12afx 13afx 23afx 14afx 24afx 34afx 15afx 25afx 35afx 
               45afx 12bfx 13bfx 23bfx 14bfx 24bfx 34bfx 15bfx 25bfx 
               35bfx 45bfx abfx 12cfx 13cfx 23cfx 14cfx 24cfx 34cfx 
               15cfx 25cfx 35cfx 45cfx acfx bcfx 12dfx 13dfx 23dfx 
               14dfx 24dfx 34dfx 15dfx 25dfx 35dfx 45dfx adfx bdfx 
               cdfx 12efx 13efx 23efx 14efx 24efx 34efx 15efx 25efx 
               35efx 45efx aefx befx cefx defx 1234gx 1235gx 1245gx 
               1345gx 2345gx 12agx 13agx 23agx 14agx 24agx 34agx 
               15agx 25agx 35agx 45agx 12bgx 13bgx 23bgx 14bgx 24bgx 
               34bgx 15bgx 25bgx 35bgx 45bgx abgx 12cgx 13cgx 23cgx 
               14cgx 24cgx 34cgx 15cgx 25cgx 35cgx 45cgx acgx bcgx 
               12dgx 13dgx 23dgx 14dgx 24dgx 34dgx 15dgx 25dgx 35dgx 
               45dgx adgx bdgx cdgx 12egx 13egx 23egx 14egx 24egx 
               34egx 15egx 25egx 35egx 45egx aegx begx cegx degx 
               12fgx 13fgx 23fgx 14fgx 24fgx 34fgx 15fgx 25fgx 35fgx 
               45fgx afgx bfgx cfgx dfgx efgx 1234hx 1235hx 1245hx 
               1345hx 2345hx 12ahx 13ahx 23ahx 14ahx 24ahx 34ahx 
               15ahx 25ahx 35ahx 45ahx 12bhx 13bhx 23bhx 14bhx 
               24bhx 34bhx 15bhx 25bhx 35bhx 45bhx abhx 12chx 13chx 
               23chx 14chx 24chx 34chx 15chx 25chx 35chx 45chx achx 
               bchx 12dhx 13dhx 23dhx 14dhx 24dhx 34dhx 15dhx 25dhx 
               35dhx 45dhx adhx bdhx cdhx 12ehx 13ehx 23ehx 14ehx 
               24ehx 34ehx 15ehx 25ehx 35ehx 45ehx aehx behx cehx 
               dehx 12fhx 13fhx 23fhx 14fhx 24fhx 34fhx 15fhx 25fhx 
               35fhx 45fhx afhx bfhx cfhx dfhx efhx 12ghx 13ghx 23ghx 
               14ghx 24ghx 34ghx 15ghx 25ghx 35ghx 45ghx aghx bghx 
               cghx dghx eghx fghx 1234ix 1235ix 1245ix 1345ix 2345ix 
               12aix 13aix 23aix 14aix 24aix 34aix 15aix 25aix 35aix 
               45aix 12bix 13bix 23bix 14bix 24bix 34bix 15bix 25bix 
               35bix 45bix abix 12cix 13cix 23cix 14cix 24cix 34cix 
               15cix 25cix 35cix 45cix acix bcix 12dix 13dix 23dix 
               14dix 24dix 34dix 15dix 25dix 35dix 45dix adix bdix 
               cdix 12eix 13eix 23eix 14eix 24eix 34eix 15eix 25eix 
               35eix 45eix aeix beix ceix deix 12fix 13fix 23fix 14fix 
               24fix 34fix 15fix 25fix 35fix 45fix afix bfix cfix dfix 
               efix 12gix 13gix 23gix 14gix 24gix 34gix 15gix 25gix 
               35gix 45gix agix bgix cgix dgix egix fgix 12hix 13hix 
               23hix 14hix 24hix 34hix 15hix 25hix 35hix 45hix ahix 
               bhix chix dhix ehix fhix ghix 1234jx 1235jx 1245jx 
               1345jx 2345jx 12ajx 13ajx 23ajx 14ajx 24ajx 34ajx 15ajx 
               25ajx 35ajx 45ajx 12bjx 13bjx 23bjx 14bjx 24bjx 34bjx 
               15bjx 25bjx 35bjx 45bjx abjx 12cjx 13cjx 23cjx 14cjx 
               24cjx 34cjx 15cjx 25cjx 35cjx 45cjx acjx bcjx 12djx 
               13djx 23djx 14djx 24djx 34djx 15djx 25djx 35djx 45djx 
               adjx bdjx cdjx 12ejx 13ejx 23ejx 14ejx 24ejx 34ejx 
               15ejx 25ejx 35ejx 45ejx aejx bejx cejx dejx 12fjx 
               13fjx 23fjx 14fjx 24fjx 34fjx 15fjx 25fjx 35fjx 45fjx 
               afjx bfjx cfjx dfjx efjx 12gjx 13gjx 23gjx 14gjx 
               24gjx 34gjx 15gjx 25gjx 35gjx 45gjx agjx bgjx cgjx 
               dgjx egjx fgjx 12hjx 13hjx 23hjx 14hjx 24hjx 34hjx 
               15hjx 25hjx 35hjx 45hjx ahjx bhjx chjx dhjx ehjx 
               fhjx ghjx 12ijx 13ijx 23ijx 14ijx 24ijx 34ijx 15ijx 
               25ijx 35ijx 45ijx aijx bijx cijx dijx eijx fijx gijx 
               hijx 1234kx 1235kx 1245kx 1345kx 2345kx 12akx 13akx 
               23akx 14akx 24akx 34akx 15akx 25akx 35akx 45akx 
               12bkx 13bkx 23bkx 14bkx 24bkx 34bkx 15bkx 25bkx 
               35bkx 45bkx abkx 12ckx 13ckx 23ckx 14ckx 24ckx 
               34ckx 15ckx 25ckx 35ckx 45ckx ackx bckx 12dkx 13dkx 
               23dkx 14dkx 24dkx 34dkx 15dkx 25dkx 35dkx 45dkx adkx
               bdkx cdkx 12ekx 13ekx 23ekx 14ekx 24ekx 34ekx 15ekx 
               25ekx 35ekx 45ekx aekx bekx cekx dekx 12fkx 13fkx 
               23fkx 14fkx 24fkx 34fkx 15fkx 25fkx 35fkx 45fkx 
               afkx bfkx cfkx dfkx efkx 12gkx 13gkx 23gkx 14gkx 
               24gkx 34gkx 15gkx 25gkx 35gkx 45gkx agkx bgkx cgkx 
               dgkx egkx fgkx 12hkx 13hkx 23hkx 14hkx 24hkx 34hkx 
               15hkx 25hkx 35hkx 45hkx ahkx bhkx chkx dhkx ehkx 
               fhkx ghkx 12ikx 13ikx 23ikx 14ikx 24ikx 34ikx 
               15ikx 25ikx 35ikx 45ikx aikx bikx cikx dikx eikx 
               fikx gikx hikx 12jkx 13jkx 23jkx 14jkx 24jkx 34jkx 
               15jkx 25jkx 35jkx 45jkx ajkx bjkx cjkx djkx ejkx 
               fjkx gjkx hjkx ijkx ) + 
               [""]  # 0 blocks

  block_coords '1' => [:g3, :c7],
               '2' => [:f4, :d6],
               '3' => [:h8, :b2],
               '4' => [:g7, :c3],
               '5' => [:f6, :d4],
               'a' => [:f2, :h4, :d8, :b6],
               'b' => [:g4, :f3, :d7, :c6],
               'c' => [:i8, :h9, :b1, :a2],
               'd' => [:h7, :g8, :c2, :b3],
               'e' => [:g6, :f7, :d3, :c4],
               'f' => [:i7, :g9, :c1, :a3],
               'g' => [:h6, :f8, :d2, :b4],
               'h' => [:i6, :f9, :d1, :a4],
               'i' => [:h5, :e8, :e2, :b5],
               'j' => [:g5, :e7, :e3, :c5],
               'k' => [:f5, :e6, :e4, :d5],
               'x' => [:e5]
end

