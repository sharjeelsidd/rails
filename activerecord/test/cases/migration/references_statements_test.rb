require "cases/migration/helper"

module ActiveRecord
  class Migration
    class ReferencesStatementsTest < ActiveRecord::TestCase
      include ActiveRecord::Migration::TestHelper

      self.use_transactional_fixtures = false

      def setup
        super
        @table_name = :test_models

        add_column table_name, :supplier_id, :integer
        add_index table_name, :supplier_id
      end

      def test_creates_reference_id_column
        add_reference table_name, :user
        assert column_exists?(table_name, :user_id, :integer)
      end

      def test_does_not_create_reference_type_column
        add_reference table_name, :taggable
        refute column_exists?(table_name, :taggable_type, :string)
      end

      def test_creates_reference_type_column
        add_reference table_name, :taggable, polymorphic: true
        assert column_exists?(table_name, :taggable_type, :string)
      end

      def test_creates_reference_id_index
        add_reference table_name, :user, index: true
        assert index_exists?(table_name, :user_id)
      end

      def test_does_not_create_reference_id_index
        add_reference table_name, :user
        refute index_exists?(table_name, :user_id)
      end

      def test_creates_polymorphic_index
        add_reference table_name, :taggable, polymorphic: true, index: true
        assert index_exists?(table_name, [:taggable_id, :taggable_type])
      end

      def test_creates_reference_type_column_with_default
        add_reference table_name, :taggable, polymorphic: { default: 'Photo' }, index: true
        assert column_exists?(table_name, :taggable_type, :string, default: 'Photo')
      end

      def test_creates_named_index
        add_reference table_name, :tag, index: { name: 'index_taggings_on_tag_id' }
        assert index_exists?(table_name, :tag_id, name: 'index_taggings_on_tag_id')
      end

      def test_deletes_reference_id_column
        remove_reference table_name, :supplier
        refute column_exists?(table_name, :supplier_id, :integer)
      end

      def test_deletes_reference_id_index
        remove_reference table_name, :supplier
        refute index_exists?(table_name, :supplier_id)
      end
      
      def test_does_not_delete_reference_type_column
        with_polymorphic_column do
          remove_reference table_name, :supplier

          refute column_exists?(table_name, :supplier_id, :integer)
          assert column_exists?(table_name, :supplier_type, :string)
        end
      end
      
      def test_deletes_reference_type_column
        with_polymorphic_column do
          remove_reference table_name, :supplier, polymorphic: true
          refute column_exists?(table_name, :supplier_type, :string)
        end
      end

      def test_deletes_polymorphic_index
        with_polymorphic_column do
          remove_reference table_name, :supplier, polymorphic: true
          refute index_exists?(table_name, [:supplier_id, :supplier_type])
        end
      end

      def test_add_belongs_to_alias
        add_belongs_to table_name, :user
        assert column_exists?(table_name, :user_id, :integer)
      end

      def test_remove_belongs_to_alias
        remove_belongs_to table_name, :supplier
        refute column_exists?(table_name, :supplier_id, :integer)
      end

      private

      def with_polymorphic_column
        add_column table_name, :supplier_type, :string
        add_index table_name, [:supplier_id, :supplier_type]

        yield
      end
    end
  end
end
