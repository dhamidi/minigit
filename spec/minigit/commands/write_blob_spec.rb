require 'spec_helper'

describe MiniGit::Commands::WriteBlob, step1: true do
  it 'returns an ID equal to the SHA1 of the hashed contents' do
    blobs = ['a', 'b', 'c']
    blobs.each do |contents|
      blob_id = write_blob.call(contents)
      expect(blob_id).to eq(sha1_of(contents)), contents
    end
  end

  it "stores an object with the given ID in the repository's object store" do
    blob_id = write_blob.call('hello, world')
    blob = repository.objects.fetch(blob_id)
    expect(blob.type).to eq(:blob)
    expect(blob.contents).to eq('hello, world')
  end

  it "does not store the same object more than once" do
    blob_id = write_blob.call('hello, world')
    size_before = repository.objects.size
    other_blob_id = write_blob.call('hello, world')
    size_after = repository.objects.size

    expect(other_blob_id).to eq(blob_id), 'blob ID changed'
    expect(size_after).to eq(size_before), 'number of objects changed'
  end
end
