
class Ataxx < Rules

  BLOCKS = %w( x         # 1 block

# 2 blocks:
               1 2 3
# 3 blocks:
               1x 2x 3x
# 4 blocks:
               12 13 14 15 16 23 25 26 36 a b c g h
# 5 blocks:
               12x 13x 14x 15x 16x 23x 25x 26x 36x ax bx cx gx hx
# 6 blocks:
               123 124 125 126 134 135 136 234 235 236 1a 1b 1c 1d
               1e 1f 1g 1h 2a 2b 2c 2d 2e 2f 2g 2h 3a 3b 3c 3d 3e 3f 3g 3h
# 7 blocks:
               123x 124x 125x 126x 134x 135x 136x 234x 235x 236x 1ax
               1bx 1cx 1dx 1ex 1fx 1gx 1hx 2ax 2bx 2cx 2dx 2ex 2fx 2gx 2hx
               3ax 3bx 3cx 3dx 3ex 3fx 3gx 3hx
# 8 blocks:
               12a 12b 12c 12d 12e 12f 12g 12h
               13a 13b 13c 13d 13e 13f 13g 12h
               14a 14b 14c 14g 14h
               15a 15b 15c 15g 15h
               16a 16b 16c 16g 16h
               23a 23b 23c 23d 23e 23f 23g 23h
               24a 24b 24c 25a 25b 25c 25g 26g 26a 26b 26c 26g 26h
               34a 34b 34c 35a 35b 35c 36a 36b 36c 36g 36h
               ab ac ad ae af ag ah bc be bf bg bh cf cg ch gh
               1234 1245 1246 1256 2345 2346 2356 1345 1346 1356 2345 2346 2356
# 9 blocks:
               12ax 12bx 12cx 12dx 12ex 12fx 12gx
               13ax 13bx 13cx 13dx 13ex 13fx 13gx
               14ax 14bx 14cx 14g 14hx
               15ax 15bx 15cx 15g 15hx
               16ax 16bx 16cx 16g 16hx
               23ax 23bx 23cx 23dx 23ex 23fx 23gx 23hx
               24ax 24bx 24cx 25ax 25bx 25cx 25g 26gx 26ax 26bx 26cx 26g 26hx
               34ax 34bx 34cx 35ax 35bx 35cx 36ax 36bx 36cx 36gx 36hx
               abx acx adx aex afx agx ahx bcx bex bfx bgx bhx cfx cgx chx ghx
               1234x 1245x 1246x 1256x 2345x 2346x 2356x 1345x 1346x 1356x 2345x
               2346x 2356x
# 10 blocks:
               123a 123b 123c 123d 123e 123f 123g 123h
               124a 124b 124c 124g 124h
               125a 125b 125c 125d 125e 125f 125g 125h
               126a 126b 126c 126d 126e 126f 126g 126h
               134a 134b 134c 134g 134h
               135a 135b 135c 135d 135e 135f 135g 135h
               136a 136b 136c 136d 136e 136f 136g 136h
               145a 145b 145c 145g 145h
               146a 146b 146c 146g 146h
               156a 156b 156c 156g 156h
               234a 234b 234c 234g 234h
               235a 235b 235c 235d 235e 235f 235g 235h
               236a 236b 236c 236d 236e 236f 236g 236h
               1ab 1ac 1ad 1ae 1af 1ag 1ah 1bc 1be 1bf 1bg 1bh 1cf 1cg 1ch 1gh
               1dg 1dh 1gh
               2ab 2ac 2ad 2ae 2af 2ag 2ah 2bc 2be 2bf 2bg 2bh 2cf 2cg 2ch 2gh
               2dg 2dh 2gh
               3ab 3ac 3ad 3ae 3af 3ag 3ah 3bc 3be 3bf 3bg 3bh 3cf 3cg 3ch 3gh
               3dg 3dh 3gh
               4ab 5ab 6ab 4ac 5ac 6ac 4bc 5bc 6bc 12345x 12346x 12356x
# 11 blocks:
               123ax 123bx 123cx 123dx 123ex 123fx 123gx 123hx
               124ax 124bx 124cx 124gx 124hx
               125ax 125bx 125cx 125dx 125ex 125fx 125gx 125hx
               126ax 126bx 126cx 126dx 126ex 126fx 126gx 126hx
               134ax 134bx 134cx 134gx 134hx
               135ax 135bx 135cx 135dx 135ex 135fx 135gx 135hx
               136ax 136bx 136cx 136dx 136ex 136fx 136gx 136hx
               145ax 145bx 145cx 145gx 145hx
               146ax 146bx 146cx 146gx 146hx
               156ax 156bx 156cx 156gx 156hx
               234ax 234bx 234cx 234gx 234hx
               235ax 235bx 235cx 235dx 235ex 235fx 235gx 235hx
               236ax 236bx 236cx 236dx 236ex 236fx 236gx 236hx
               1abx 1acx 1adx 1aex 1afx 1agx 1ahx 1bcx 1bex 1bfx 1bgx 1bhx 1cfx
               1cgx 1chx 1ghx 1dgx 1dhx 1ghx
               2abx 2acx 2adx 2aex 2afx 2agx 2ahx 2bcx 2bex 2bfx 2bgx 2bhx 2cfx
               2cgx 2chx 2ghx 2dgx 2dhx 2ghx
               3abx 3acx 3adx 3aex 3afx 3agx 3ahx 3bcx 3bex 3bfx 3bgx 3bhx 3cfx
               3cgx 3chx 3ghx 3dgx 3dhx 3ghx
               4abx 5abx 6abx 4acx 5acx 6acx 4bcx 5bcx 6bcx 12345x 12346x 
               12356x ) + 
               [""]  # 0 blocks

  BLOCK_COORDS = { 
    '1' => [:a4, :g4],
    '2' => [:b4, :f4],
    '3' => [:c4, :e4],
    '4' => [:d1, :d7],
    '5' => [:d2, :d6],
    '6' => [:d3, :d5],
    'a' => [:a2, :a6, :g2, :g6],
    'b' => [:a3, :a5, :g3, :g5],
    'c' => [:b3, :b5, :f3, :f5],
    'd' => [:b1, :b7, :f1, :f7],
    'e' => [:c1, :c7, :e1, :e7],
    'f' => [:c2, :c7, :e2, :e7],
    'g' => [:b2, :b6, :f2, :f6],
    'h' => [:c3, :c5, :e3, :e5],
    'x' => [:d4]
  }

  def set_blocks( p )
    p.scan( /./m ) do |c|
      board[*BLOCK_COORDS[c]] = :x
    end
    p
  end

  def set_rand_blocks
    set_blocks( BLOCKS[rand( BLOCKS.length )] )
  end

  def clear_blocks
    board[*board.occupied[:x]] = nil
    @block_pattern = ""
  end

end

