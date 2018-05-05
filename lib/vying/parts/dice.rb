
# frozen_string_literal: true

class Die

  attr_reader :up, :color, :faces

  def initialize(up, color=:white, faces=[1, 2, 3, 4, 5, 6])
    @up, @color, @faces = up, color, faces
  end

  def roll(rng=Kernel)
    @up = faces[rng.rand(faces.length)]
  end

  def eql?(other)
    other && other.respond_to?(:up) && up == other.up &&
    other.respond_to?(:color) && color == other.color
  end

  def ==(other)
    eql?(other)
  end

  def hash
    [up, color, faces].hash
  end

  def to_s
    up.to_s
  end
end

class Dice

  def initialize(dice=[])
    @dice = dice
  end

  def [](i)
    @dice[i]
  end

  def length
    @dice.length
  end

  def each
    @dice.each { |die| yield die }
  end

  def roll(rng=Kernel)
    @dice.each { |die| die.roll(rng) }
  end

  def include?(array)
    sorted = @dice.map(&:up).sort
    array = array.sort

    i, j = 0, 0

    while j < array.length
      return false if sorted[i].nil? || sorted[i] > array[j]

      j += 1 if sorted[i] == array[j]
      i += 1
    end

    j == array.length
  end

  def to_a
    @dice.dup
  end

  def eql?(other)
    other.respond_to?(:length) && other.respond_to?(:to_a) &&
    length == other.length && to_a == other.to_a
  end

  def ==(other)
    eql?(other)
  end

  def hash
    to_a.hash
  end

end
