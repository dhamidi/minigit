module MiniGit
  Error = Class.new(StandardError)
  Blob = Struct.new(:id, :contents) do
    def type
      :blob
    end
  end

  Tree = Struct.new(:id, :contents) do
    def type
      :tree
    end
  end

  Commit = Struct.new(:id, :parent_id, :tree_id, :message) do
    def type
      :commit
    end
  end

  WorkingCopy = Struct.new(:head, :contents, :repository, :symbolic_ref) do
    def commit!(message)
      self.head = commit.call(
        parent_id: head,
        message: message,
        tree_id: persist_tree(contents)
      )
      update_ref.call(symbolic_ref, head) if symbolic_ref
      self.head
    end

    private

    def persist_tree(contents)
      tree_contents = {}
      contents.each do |(name, object)|
        case object
        when Hash
          tree_contents[name] = persist_tree(object)
        else
          tree_contents[name] = write_blob.call(object)
        end
      end

      write_tree.call(tree_contents)
    end

    def update_ref
      @update_ref ||= Commands::UpdateRef.new(repository)
    end

    def commit
      @commit ||= Commands::Commit.new(repository)
    end
    
    def write_blob
      @write_blob ||= Commands::WriteBlob.new(repository)
    end

    def write_tree
      @write_tree ||= Commands::WriteTree.new(repository)
    end
  end

  class Repository
    def initialize
      @objects = {}
      @refs = {}
    end

    attr_reader :objects, :refs

    def has_object?(object_id)
      objects.key?(object_id)
    end

    def resolve(ref)
      object_id = refs.fetch(ref, ref)
      require_object!(object_id)
      object_id
    end

    def fetch(ref_or_object_id)
      object_id = resolve(ref_or_object_id)
      objects.fetch(object_id)
    end

    def require_object!(object_id, type: nil)
      object = objects[object_id]
        
      if object && type && !Array(type).include?(object.type)
        raise Error.new(
                "type error: #{object_id} is #{object.type}, want #{type}"
              )
      end

      raise Error.new("no such object: #{object_id}") unless
        object
    end
  end

  module Commands
    class WriteBlob
      def initialize(repository)
        @repository = repository
      end
      attr_reader :repository
      
      def call(blob_contents)
        blob_id = Digest::SHA1.hexdigest(blob_contents)
        repository.objects[blob_id] = Blob.new(blob_id, blob_contents)
        blob_id
      end
    end
  end

  module Commands
    class WriteTree
      def initialize(repository)
        @repository = repository
      end

      attr_reader :repository

      def call(tree_contents)
        tree_id = build_id(tree_contents)
        tree = Tree.new(tree_id, tree_contents)
        repository.objects[tree_id] = tree
        tree_id
      end

      private

      def build_id(tree_contents)
        components = tree_contents.map do |(name, object_id)|
          repository.require_object!(object_id, type: [:tree, :blob])
          "#{object_id} #{name}"
        end
        Digest::SHA1.hexdigest(components.join("\n"))
      end
    end
  end

  module Commands
    class Commit
      def initialize(repository)
        @repository = repository
      end

      attr_reader :repository

      def call(parent_id: nil, message:, tree_id:)
        id = build_id(parent_id, tree_id, message)
        commit = MiniGit::Commit.new(id, parent_id, tree_id, message)
        repository.objects[id] = commit
        id
      end

      private

      def build_id(parent_id, tree_id, message)
        repository.require_object!(parent_id, type: :commit) if parent_id
        repository.require_object!(tree_id, type: :tree)
        id_src = [parent_id.to_s, tree_id, message].join("\n")
        Digest::SHA1.hexdigest(id_src)
      end
    end
  end

  module Commands
    class Checkout
      def initialize(repository)
        @repository = repository
      end

      attr_reader :repository

      def call(ref)
        return empty_checkout if ref.nil?
        object = repository.fetch(ref)
        WorkingCopy.new(
          object.id,
          fetch_all(object.tree_id),
          repository,
          repository.resolve(ref) != ref ? ref : nil
        )
      end

      private

      def empty_checkout
        WorkingCopy.new(
          nil,
          {},
          repository
        )
      end
      
      def fetch_all(tree_id)
        result = {}
        tree = repository.objects.fetch(tree_id)
        tree.contents.each do |(name, object_id)|
          object = repository.objects.fetch(object_id)
          case object.type
          when :blob
            result[name] = object.contents
          when :tree
            result[name] = fetch_all(object_id)
          end
        end
        result
      end
    end
  end

  module Commands
    class UpdateRef
      def initialize(repository)
        @repository = repository
      end

      attr_reader :repository

      def call(refname, object_id)
        repository.require_object!(object_id)
        repository.refs.store(refname, object_id)
      end
    end
  end
end
