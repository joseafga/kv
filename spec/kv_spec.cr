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

  it "Delete a KV Namespace" do
    response = KV.delete "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    response.should be_nil
  end
end
