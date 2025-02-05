require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")
module RestResource
  describe Resource do
    let(:rest_crud) {double :rest_crud, :find => "{}", :create => "{}"}
    let(:find_params) {123}
    let(:create_params) {{"attr1" => "val1"}}
    let(:klass) {
      Class.new(Resource) do
      def self.site
        "http://www.example.com"
      end

      def self.resource_name
        "resources"
      end

      end
    }

    %w(find create).each do |method_name|
      describe ".#{method_name}" do
        before(:each) do
          RestCrud.stub(:new).and_return rest_crud
        end


        it "should initialize a rest crud object" do
          RestCrud.should_receive(:new).with("http://www.example.com/resources").and_return rest_crud
          klass.send(method_name, send("#{method_name}_params"))
        end

        it "should ask rest crud to do the finding" do
          rest_crud.should_receive(method_name).with(send("#{method_name}_params"))
          klass.send(method_name, send("#{method_name}_params"))
        end

        it "should intialize a resource object" do
          rest_crud.stub(:find).and_return(ActiveSupport::JSON.encode("attr1" => "val1", "attr2" => "val2"))
          object = klass.send(method_name, send("#{method_name}_params"))
          object.should be_a klass
        end

      end
    end

    describe ".new" do
      let(:params) { ActiveSupport::JSON.encode( {"attr1" => "val1", "attr2" => "val2"} ) }
      let(:resource) {klass.new(params)}
      {"attr1" => "val1", "attr2" => "val2"}.each_pair do |attr, val|
        it "should generate '#{attr}' method and return '#{val}'" do
          resource.send(attr).should == val
        end
      end

      context "when the objects are initialized multiple times" do
        attr_reader :resource1
        before(:each) do
          @resource1 = klass.new( ActiveSupport::JSON.encode("attr1" => "val1"))
          klass.new( ActiveSupport::JSON.encode("attr1" => "val2"))
        end

        it "should work" do
          resource1.attr1.should == "val1"
        end
      end
    end
      end
  end
