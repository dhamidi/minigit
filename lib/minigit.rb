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
    end
  end

  class Repository
    def initialize
      @objects = {}
      @refs = {}
    end

    attr_reader :objects, :refs

    def has_object?(object_id)
    end

    def resolve(ref)
    end

    def fetch(ref_or_object_id)
    end

    def require_object!(object_id, type: nil)
    end
  end

  module Commands
    class WriteBlob
      def initialize(repository)
        @repository = repository
      end
      attr_reader :repository
      
      def call(blob_contents)
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
      end
    end
  end
end
