require "./spec_helper"

describe KV do
  spec_namespace_id = ""

  it "List KV Namespaces" do
    list = Store.list
    list.should be_a(Array(KV::Namespace))
  end

  it "Create a KV Namespace" do
    namespace = Store.create "some title"
    spec_namespace_id = namespace.id
    namespace.should be_a(KV::Namespace)
  end

  it "Get a KV Namespace" do
    namespace = Store.get spec_namespace_id
    namespace.should be_a(KV::Namespace)
  end

  it "Rename a KV Namespace" do
    namespace = Store.rename spec_namespace_id, "renamed title"
    namespace.should be_a(KV::Namespace)
  end

  it "Write key value pair with metadata" do
    namespace = Store.get spec_namespace_id
    namespace.write("foo", "bar", metadata: {"count" => [1,2,3]}.to_json).should be_nil
  end

  it "Read key value pair" do
    namespace = Store.get spec_namespace_id
    namespace.read("foo").should eq "bar"
  end

  it "List a KV Namespace keys" do
    namespace = Store.get spec_namespace_id
    list = namespace.keys
    key = list.find! { |key| key.name == "foo" }
    key.name.should eq "foo"
  end

  it "Write key value pair without metadata" do
    namespace = Store.get spec_namespace_id
    namespace.write("John", "Doe").should be_nil
  end

  it "Write key value pair with expiration" do
    namespace = Store.get spec_namespace_id
    namespace.write("Expire in 60 seconds", "My precious", expiration_ttl: 60).should be_nil
  end

  it "Delete a KV Namespace" do
    Store.delete(spec_namespace_id).should be_nil
  end
end
