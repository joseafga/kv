require "./spec_helper"

describe KV do
  spec_namespace_id = ""

  it "List Namespaces" do
    list = Store.list
    list.should be_a(Array(KV::Namespace))
  end

  it "Create a Namespace" do
    namespace = Store.create "some title"
    spec_namespace_id = namespace.id
    namespace.should be_a(KV::Namespace)
  end

  it "Get a Namespace" do
    namespace = Store.get spec_namespace_id
    namespace.should be_a(KV::Namespace)
  end

  it "Rename a Namespace" do
    namespace = Store.rename spec_namespace_id, "renamed title"
    namespace.should be_a(KV::Namespace)
  end

  it "Write key value pair with metadata" do
    namespace = Store.get spec_namespace_id
    namespace.write("foo", "bar", metadata: {"count" => [1, 2, 3]}).should be_nil
  end

  it "Read key value pair" do
    namespace = Store.get spec_namespace_id
    namespace.read("foo").should eq "bar"
  end

  it "List a Namespace keys" do
    namespace = Store.get spec_namespace_id
    k = namespace.keys.find! { |key| key.name == "foo" }
    k.name.should eq "foo"
  end

  it "Write key value pair without metadata" do
    namespace = Store.get spec_namespace_id
    namespace.write("John", "Doe").should be_nil
  end

  it "Write key value pair with expiration" do
    namespace = Store.get spec_namespace_id
    namespace.write("Expire in 60 seconds", "My precious", expiration_ttl: 60).should be_nil
  end

  it "Read the metadata for a key" do
    namespace = Store.get spec_namespace_id
    namespace.metadata("foo").should eq({"count" => [1, 2, 3]})
  end

  it "Delete key-value pair" do
    namespace = Store.get spec_namespace_id
    namespace.delete("John").should be_nil
  end

  it "Get multiple key-value pairs" do
    namespace = Store.get spec_namespace_id
    keys = %w[foo]

    response = namespace.read_bulk(keys)
    response["values"]["foo"].should eq "bar"
  end

  it "Write multiple key-value pairs" do
    namespace = Store.get spec_namespace_id

    bulk = ["one", "two", "three"].map_with_index do |num, index|
      KV::Namespace::BulkKey.new(num, index + 1)
    end

    response = namespace.write_bulk(bulk)
    response.successful_key_count.should eq 3
  end

  it "Delete multiple key-value pairs" do
    namespace = Store.get spec_namespace_id
    keys = %w[one two three]

    response = namespace.delete_bulk(keys)
    response.successful_key_count.should eq 3
  end

  # Blocks
  it "List Namespaces with Block" do
    Store.list do |ns|
      ns.should be_a(Array(KV::Namespace))
    end
  end

  it "Get a Namespace with Block" do
    Store.get spec_namespace_id do |ns|
      ns.write("block", "list")
      k = ns.keys
      k.find! { |key| key.name == "block" }.name.should eq "block"
    end
  end

  # Errors
  it "Namespace Not Found" do
    expect_raises(KV::ResponseError, "Error 10011: could not parse UUID from request's namespace_id") do
      Store.get "bad-uuid"
    end
  end

  it "Key Not Found" do
    expect_raises(KV::ResponseError, "Error 10009: get: 'key not found'") do
      namespace = Store.get spec_namespace_id
      namespace.read("bad-key")
    end
  end

  # Remove test namespace at end
  it "Remove a Namespace" do
    Store.delete(spec_namespace_id).should be_nil
  end
end
