require "./spec_helper"

describe KV do
  it "List KV Namespaces" do
    list = KV.list
    list.should be_a(Array(KV::Namespace))
  end

  it "Get a KV Namespace" do
    namespace = KV.get "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    namespace.should be_a(KV::Namespace)
  end

  it "Create a KV Namespace" do
    namespace = KV.create "some title"
    namespace.should be_a(KV::Namespace)
  end

  it "Rename a KV Namespace" do
    namespace = KV.rename "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "renamed title"
    namespace.should be_a(KV::Namespace)
  end

  it "Write key value pair with metadata" do
    pp KV.write "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "foo", "bar", metadata: {"count" => [1,2,3]}.to_json
  end

  it "Read key value pair" do
    pp KV.read "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "foo"
  end

  it "List a KV Namespace keys" do
    list = KV.keys "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    list.find! { |key| key.name == "foo" }.name.should eq "foo"
  end

  it "Write key value pair without metadata" do
    pp KV.write "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "John", "Doe"
  end

  it "Write key value pair with expiration" do
    pp KV.write "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "Expire in 60 seconds", "My precious", expiration_ttl: 60
  end

  it "Delete a KV Namespace" do
    response = KV.delete "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    response.should be_nil
  end
end
