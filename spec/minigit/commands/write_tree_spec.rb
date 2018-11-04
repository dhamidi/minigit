require 'spec_helper'

describe MiniGit::Commands::WriteTree, step2: true do
  it "returns an ID equal to the SHA1 of the tree's content listing" do
    expected_tree_id = sha1_of(
      "#{blobs[0]} 1_first",
      "#{blobs[1]} 2_second",
      "#{blobs[2]} 3_third"
    )

    expect(tree_id).to eq(expected_tree_id), 'tree ID does not match'
  end

  it "stores an object with the tree's ID in the object store" do
    id = tree_id
    tree = repository.objects.fetch(id)
    expect(tree.type).to eq(:tree)
    expect(tree.contents).to eq(tree_contents)
  end

  it 'allows storing nested trees' do
    inner_id = write_tree.call('inner' => blobs[0])
    outer_id = write_tree.call('outer' => inner_id)
    outer = repository.objects.fetch(outer_id)

    expect(outer.contents['outer']).to eq(inner_id)
  end

  it 'raises an error if the tree contents refer to non-existing objects' do
    expect {
      write_tree.call('does-not-exist' => 'invalid-object-id')
    }.to raise_git_error('no such object: invalid-object-id')
  end

  it 'raises an error if the tree contents refer to a commit', step2: false, step3: true do
    expect {
      write_tree.call('a-commit' => initial_commit_id)
    }.to raise_git_error("type error: #{initial_commit_id} is commit, want [:tree, :blob]")
  end
end
