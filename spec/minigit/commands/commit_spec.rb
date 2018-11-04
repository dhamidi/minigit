require 'spec_helper'

describe MiniGit::Commands::Commit, step3: true do
  it 'raises an error if the referenced tree does not exist' do
    expect {
      commit.call(message: 'hello',
                  tree_id: 'no-such-tree')
    }.to raise_git_error('no such object: no-such-tree')
  end

  it 'raises an error if the referenced parent commit does not exist' do
    expect {
      commit.call(message: 'hello',
                  tree_id: tree_id,
                  parent_id: 'parent-commit')
    }.to raise_git_error(
           'no such object: parent-commit'
         )
  end

  it 'raises an error if tree_id does not refer to a tree' do
    expect {
      commit.call(message: 'hello', tree_id: blobs[0])
    }.to raise_git_error("type error: #{blobs[0]} is blob, want tree")
  end

  it 'raises an error if parent_id does not refer to a commit' do
    expect {
      commit.call(message: 'hello',
                  tree_id: tree_id,
                  parent_id: tree_id)
    }.to raise_git_error("type error: #{tree_id} is tree, want commit")
  end

  it 'returns a ID based on the SHA1 of the commit contents' do
    expected_id = sha1_of(
      '',
      tree_id,
      'initial commit'
    )

    commit_id = commit.call(message: 'initial commit', tree_id: tree_id)
    expect(commit_id).to eq(expected_id)
  end

  it 'includes the parent commit_id in the ID of the next commit' do
    other_tree_id = write_tree.call('a' => blobs[0])
    expected_id = sha1_of(
      initial_commit_id,
      other_tree_id,
      'next commit'
    )

    commit_id = commit.call(message: 'next commit', tree_id: other_tree_id, parent_id: initial_commit_id)
    expect(commit_id).to eq(expected_id)
  end

  it 'writes a commit object to the object store' do
    commit_id = initial_commit_id
    commit = repository.objects.fetch(commit_id)
    expect(commit.type).to eq(:commit)
    expect(commit.parent_id).to be_nil
    expect(commit.message).to eq('initial commit')
    expect(commit.tree_id).to eq(tree_id)
  end
end
