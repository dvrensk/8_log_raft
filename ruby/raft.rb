#! /usr/bin/ruby -w
require 'matrix'

class Raft

  LOGS = File.read(File.expand_path('../../logs.txt', __FILE__)).split("\n")

  def self.solve
    each_split do |lower, upper|
      solver = new(lower, upper)
      solver.solve
      if solver.has_solution?
        puts solver
        puts "---------"
      end
    end
  end

  def self.each_split
    logs = LOGS.map { |s| Log.new(s) }
    # To avoid solutions that are just a swap of lower and upper,
    # assume log 0 will always be in bottom
    logs[1..-1].combination(3) do |lower|
      lower << logs[0]
      upper = logs - lower
      yield lower, upper
    end
  end

  attr_reader :lower, :upper
  def initialize(lower, upper)
    @lower, @upper = LogSet.new(lower), LogSet.new(upper)
    @solutions = []
  end

  def solve
    return unless plausible?
    find_one_solution
  end

  def plausible?
    lower.hole_count >= upper.peg_count &&
      upper.hole_count >= lower.peg_count
  end

  def find_one_solution
    @lower.permutations do |lower|
      @upper.permutations do |upper|
        if lower.fits?(upper)
          @solutions << [lower, upper]
          return
        end
      end
    end
  end

  def has_solution?
    @solutions.any?
  end

  def to_s
    @solutions.map do |lower,upper|
      lower.to_s + "\n---\n" + upper.to_s
    end.join("\n==\n")
  end

  class Log
    def initialize(s)
      @s = s
      @val = s.chars.map { |c| {'o' => 0, '.' => 1, 'x' => 2}[c] }
    end

    def val(reverse = false)
      reverse ? @val.reverse : @val
    end

    def hole_count
      @val.count 0
    end

    def peg_count
      @val.count 2
    end

    def to_s(reverse = false)
      reverse ? @s.reverse : @s
    end
  end

  class LogSet
    def initialize(logs)
      @logs = logs
    end

    def permutations
      @logs.permutation do |logs|
        (2 ** logs.size).times do |n|
          yield LogConfiguration.new(logs, n)
        end
      end
    end

    def hole_count
      @logs.map(&:hole_count).inject(:+)
    end

    def peg_count
      @logs.map(&:peg_count).inject(:+)
    end

    def to_s
      @logs.map(&:to_s).inspect
    end
  end

  class LogConfiguration
    def initialize(logs, n)
      @logs, @n = logs, n
    end

    def fits?(other)
      apply(other).to_a.flatten.all? { |v| v < 3 }
    end

    def apply(other)
       matrix + other.matrix.t
    end

    def matrix
      Matrix[*@logs.each_with_index.map { |log,i| log.val(2 ** i & @n > 0) }]
    end

    def to_s
      @logs.each_with_index.map { |log,i| log.to_s(2 ** i & @n > 0) }.join("\n")
    end
  end
end

Raft.solve
