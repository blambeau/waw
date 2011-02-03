require File.expand_path('../../spec_helper', __FILE__)
describe 'Disjunctive validators' do
  
  it "should be ok to put Integer|missing" do
    signature = Waw::Validation.signature {
      validation :id, Integer | missing, :bad_id
    }
  end
  
  it "Integer|missing should correctly accept missings" do
    signature = Waw::Validation.signature {
      validation :id, Integer | missing, :bad_id
    }
    signature.allows?(:id => nil).should be_true
    signature.allows?(:id => "").should be_true
  end
  
  it "Integer|missing should correctly accept integers as well" do
    signature = Waw::Validation.signature {
      validation :id, Integer | missing, :bad_id
    }
    signature.allows?(:id => 12).should be_true
    signature.allows?(:id => "12").should be_true
  end
  
  it "Integer|missing should correctly handle bulk conversions" do
    validator = (Waw::Validation.integer | Waw::Validation.missing)
    ok, values = validator.convert_and_validate(1, nil, 12, "1", "2", "")
    ok.should be_true
    values.should == [1, nil, 12, 1, 2, nil]
  end

end