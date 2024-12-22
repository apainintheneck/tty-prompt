# frozen_string_literal: true

RSpec.describe TTY::Prompt::Paginator, "#paginate" do
  it "ignores per_page when equal items " do
    list = %w[a b c d]
    paginator = described_class.new(per_page: 4)

    expect(paginator.paginate(list, 1).to_a).to eq([
      ["a", 0], ["b", 1], ["c", 2], ["d", 3]
    ])
  end

  it "ignores per_page when less items " do
    list = %w[a b c d]
    paginator = described_class.new(per_page: 5)

    expect(paginator.paginate(list, 1).to_a).to eq([
      ["a", 0], ["b", 1], ["c", 2], ["d", 3]
    ])
  end

  it "paginates items matching per_page count" do
    list = %w[a b c d e f]
    paginator = described_class.new(per_page: 3)

    expect(paginator.paginate(list, 1).to_a).to eq([["a", 0], ["b", 1], ["c", 2]])
    expect(paginator.paginate(list, 2).to_a).to eq([["a", 0], ["b", 1], ["c", 2]])
    expect(paginator.paginate(list, 3).to_a).to eq([["b", 1], ["c", 2], ["d", 3]])
    expect(paginator.paginate(list, 4).to_a).to eq([["c", 2], ["d", 3], ["e", 4]])
    expect(paginator.paginate(list, 5).to_a).to eq([["d", 3], ["e", 4], ["f", 5]])
    expect(paginator.paginate(list, 6).to_a).to eq([["d", 3], ["e", 4], ["f", 5]])
    expect(paginator.paginate(list, 7).to_a).to eq([["d", 3], ["e", 4], ["f", 5]])
  end

  it "paginates items not matching per_page count" do
    list = %w[a b c d e f g]
    paginator = described_class.new(per_page: 3)

    expect(paginator.paginate(list, 1).to_a).to eq([["a", 0], ["b", 1], ["c", 2]])
    expect(paginator.paginate(list, 2).to_a).to eq([["a", 0], ["b", 1], ["c", 2]])
    expect(paginator.paginate(list, 3).to_a).to eq([["b", 1], ["c", 2], ["d", 3]])
    expect(paginator.paginate(list, 4).to_a).to eq([["c", 2], ["d", 3], ["e", 4]])
    expect(paginator.paginate(list, 5).to_a).to eq([["d", 3], ["e", 4], ["f", 5]])
    expect(paginator.paginate(list, 6).to_a).to eq([["e", 4], ["f", 5], ["g", 6]])
    expect(paginator.paginate(list, 7).to_a).to eq([["e", 4], ["f", 5], ["g", 6]])
    expect(paginator.paginate(list, 8).to_a).to eq([["e", 4], ["f", 5], ["g", 6]])
  end

  it "finds both start and end index for current selection" do
    list = %w[a b c d e f g]
    paginator = described_class.new(per_page: 3, default: 0)

    paginator.paginate(list, 2)
    expect(paginator.start_index).to eq(0)
    expect(paginator.end_index).to eq(2)

    paginator.paginate(list, 3)
    expect(paginator.start_index).to eq(1)
    expect(paginator.end_index).to eq(3)

    paginator.paginate(list, 4)
    expect(paginator.start_index).to eq(2)
    expect(paginator.end_index).to eq(4)

    paginator.paginate(list, 5)
    expect(paginator.start_index).to eq(3)
    expect(paginator.end_index).to eq(5)

    paginator.paginate(list, 7)
    expect(paginator.start_index).to eq(4)
    expect(paginator.end_index).to eq(6)

    paginator.paginate(list, 8)
    expect(paginator.start_index).to eq(4)
    expect(paginator.end_index).to eq(6)
  end

  it "always returns a page that includes the current selection" do
    list = (1..100).to_a
    list.each do |one_based_index|
      zero_based_page_indexes = described_class.new.paginate(list, one_based_index, 5).map(&:last)
      zero_based_index = one_based_index - 1
      expect(zero_based_page_indexes).to include(zero_based_index)
    end
  end

  it "starts with default selection" do
    list = %w[a b c d e f g]
    paginator = described_class.new(per_page: 3, default: 3)

    expect(paginator.paginate(list, 4).to_a).to eq([["d", 3], ["e", 4], ["f", 5]])
  end

  it "doesn't accept invalid pagination" do
    list = %w[a b c d e f g]

    paginator = described_class.new(per_page: 0)

    expect {
      paginator.paginate(list, 4)
    }.to raise_error(TTY::Prompt::InvalidArgument, /per_page must be > 0/)
  end
end
