require 'spec_helper'

describe MiniGit::Commands::UpdateRef, step5: true do
  it 'changes the value associated with a ref' do
    commit_id = initial_commit_id
    update_ref.call('master', commit_id)
    expect(checkout.call('master').head).to eq(commit_id)
  end

  it 'raises an error if the referenced object does not exist' do
    expect {
      update_ref.call('master', 'does-not-exist')
    }.to raise_git_error("no such object: does-not-exist")
  end
end
