require 'spec_helper'
module Qrb
  describe Realm, "initialize" do

    let(:realm){ Realm.new }

    context 'for building a tuple type' do
      subject{
        realm.tuple(r: Integer)
      }
      
      it{ should be_a(TupleType) }
    end

    context 'for building a sub type' do
      subject{
        realm.subtype(Integer){|i| i>=0 }
      }

      it{ should be_a(SubType) }

      it 'should apply the constraint' do
        ->{
          subject.dress(-9)
        }.should raise_error(TypeError)
      end
    end

  end
end
