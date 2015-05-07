#!/usr/bin/env ruby
# encoding: UTF-8

require 'pp'
require 'benchmark'

class LCS
  def initialize(seq1, seq2)
    @seq1, @seq2 = seq1, seq2
  end
  attr_reader :length, :dyn_length, :subsequence, :dyn_subesquence

  private
  def reset_cache
    @cache = Array.new(@seq1.length + 1) { Array.new(@seq2.length + 1, nil) }
    @cache[0].map!{|n| 0 }
    @cache.map!{|a| a[0] = 0; a }
  end

  public
  def lcs_recursive
    reset_cache
    @length = lcs(@seq1, @seq2, @seq1.length, @seq2.length)
  end

  private
  def lcs(x, y, i, j)
    if @cache[i][j].nil?
      if x[i] == y[j]
        @cache[i][j] = lcs(x, y, i-1, j-1) + 1
      else
        @cache[i][j] = [lcs(x, y, i-1, j), lcs(x, y, i, j-1)].max
      end
    else
      @cache[i][j]
    end
  end

  public
  def lcs_dynamic
    reset_cache

    1.upto(@seq1.length) do |i|
      1.upto(@seq2.length) do |j|

        if @seq1[i-1] == @seq2[j-1]
          @cache[i][j] = @cache[i-1][j-1] + 1
        else
          @cache[i][j] = [@cache[i-1][j], @cache[i][j-1]].max
        end

      end
    end

    @dyn_length = @cache.last.last
    find_sequence
  end

  private
  def find_sequence
    sequence = []

    i, j = @seq1.length-1, @seq2.length-1

    while i >= 0 && j >= 0

      if @seq1[i] == @seq2[j]
        sequence << @seq1[i]
        i -= 1 and j -= 1
      else

        current = @cache[i+1][j+1]
        left = @cache[i+1][j]
        top  = @cache[i][j+1]

        if !top.nil? && top == current
          i -= 1
        elsif !left.nil? && left == current
          j -= 1
        else
          abort "sequence error: #{[current, left, top].inspect}"
        end

      end

    end

    @subsequence = sequence.reverse.join(' ')

  end

end

describe LCS do
  let(:regxp) { /^1 2 3|1 2 1|3 4 1$/ }
  let(:a) { %w(1 2 3 4 1) }
  let(:b) { %w(3 4 1 2 1 3) }

  subject { LCS.new(a, b) }

  it 'should calculate an lcs length recursively' do
    subject.lcs_recursive
    expect(subject.length).to eq(3)
  end

  it 'should calculate the length with dynamic programming' do
    subject.lcs_dynamic
    expect(subject.dyn_length).to eq(3)
  end

  it 'should calculate at least one of the lcs matches' do
    subject.lcs_dynamic
    expect(subject.subsequence).to match(regxp)
  end

  xit 'lcs_dynamic should be faster than lcs_recursive' do

    pending 'not applicable anymore'

    a = Array.new(1_000_000) { rand(50) }
    b = Array.new(1_000_000) { rand(50) }

    lcs = LCS.new(a, b)

    recursive = Benchmark.measure { subject.lcs_recursive }
    dynamic   = Benchmark.measure { subject.lcs_dynamic   }

    expect(dynamic.real).to be < recursive.real
  end

end
