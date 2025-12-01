require "./spec_helper"

describe KV do
  it "List KV Namespaces" do
    list = KV.list
    list.should be_a(Array(KV::Namespace))
  end
end
