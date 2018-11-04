require 'spec_helper'

describe MiniGit::Commands::Checkout, step4: true do
  it 'provides access to all contents in a commit' do
    commit_id = initial_commit_id
    working_copy = checkout.call(commit_id)

    tree_contents.each do |(name, object_id)|
      blob = repository.objects.fetch(object_id)
      next unless blob.type == :blob
      expect(working_copy.contents[name]).to eq(blob.contents)
    end
  end

  it 'gives access to nested trees as nested hashes' do
    blob = repository.objects.fetch(blobs[0])
    inner_id = write_tree.call('inner' => blobs[0])
    outer_id = write_tree.call('outer' => inner_id)
    commit_id = commit.call(message: 'initial commit', tree_id: outer_id)
    working_copy = checkout.call(commit_id)

    expect(working_copy.contents['outer']['inner']).to eq(blob.contents)
  end

  it 'allows to commit changes made to the working copy' do
    working_copy = checkout.call(initial_commit_id)
    working_copy.contents['foo'] = 'bar'
    expect(working_copy.head).to eq(initial_commit_id)
    working_copy.commit!('add foo')

    new_blob_id = write_blob.call('bar')
    new_tree_id = write_tree.call(
      tree_contents.merge('foo' => new_blob_id)
    )
    new_commit_id = commit.call(message: 'add foo',
                                parent_id: initial_commit_id,
                                tree_id: new_tree_id)
    expect(working_copy.head).to eq(new_commit_id)
  end

  it 'starts a new history when checking out nil' do
    working_copy = checkout.call(nil)

    expect(working_copy.contents).to be_empty
    expect(working_copy.head).to be_nil
    expect(working_copy.symbolic_ref).to be_nil
  end

  it 'allows committing to a new history' do
    working_copy = checkout.call(nil)
    working_copy.symbolic_ref = 'new-history'
    working_copy.contents['foo'] = 'bar'
    commit_id = working_copy.commit!('a new beginning')

    expect(working_copy.head).to eq(commit_id)
    expect(repository.resolve('new-history')).to eq(commit_id)
  end

  it 'updates the symbolic ref associated with the working copy after a commit', step5: true, step4: false do
    update_ref.call('master', initial_commit_id)
    working_copy = checkout.call('master')
    working_copy.contents['bar'] = 'baz'
    commit_id = working_copy.commit!('add bar')

    expect(repository.resolve('master')).to eq(commit_id)
  end

end
