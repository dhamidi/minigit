require 'bundler'

Bundler.require(:test)

require 'minigit'
require 'digest/sha1'

module Helpers
  def new_empty_repository
    MiniGit::Repository.new
  end

  def sha1_of(*strings) 
    Digest::SHA1.hexdigest(strings.join("\n"))
  end
end

module RepositoryContext
  extend RSpec::SharedContext
  let(:repository) { new_empty_repository }
  let(:write_blob) { MiniGit::Commands::WriteBlob.new(repository) }
  let(:write_tree) { MiniGit::Commands::WriteTree.new(repository) }
  let(:commit)     { MiniGit::Commands::Commit.new(repository) }
  let(:checkout)   { MiniGit::Commands::Checkout.new(repository) }
  let(:update_ref)   { MiniGit::Commands::UpdateRef.new(repository) }
  let(:blobs) { ['a', 'b', 'c'].map(&write_blob.method(:call)) }
  let(:tree_contents) do
    {
      '1_first' => blobs[0],
      '2_second' => blobs[1],
      '3_third' => blobs[2]
    }
  end
  let(:tree_id) { write_tree.call(tree_contents) }
  let(:initial_commit_id) do
    commit.call(
      parent_id: nil,
      message: 'initial commit',
      tree_id: tree_id
    )
  end
end

RSpec::Matchers.define :raise_git_error do |expected|
  match do |actual|
    raise_error(MiniGit::Error, expected).matches?(actual)
  end

  supports_block_expectations
end

RSpec.configure do |config|
  config.include Helpers
  config.include RepositoryContext
end
