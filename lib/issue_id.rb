class IssueID < BasicObject
    attr_reader :id, :project_key, :issue_number

    def initialize(global_id, key = nil, number = nil)
        @id = global_id
        @project_key = key
        @issue_number = number
    end

    def to_i
        id.to_i
    end

    def to_s
        if project_key.present? && issue_number.present?
            to_key_number(project_key, issue_number)
        else
            id.to_s
        end
    end

    def to_param
        if project_key.present? && issue_number.present?
            to_key_number(project_key, issue_number)
        else
            id.to_param rescue id
        end
    end

    def quoted_id
        id.to_s
    end

    def is_a?(klass)
        klass == ::IssueID || id.is_a?(klass)
    end

    def kind_of?(klass)
        klass == ::IssueID || id.kind_of?(klass)
    end

    def ==(other)
        id == other
    end

    def <=>(other)
        id <=> other
    end

    def method_missing(name, *args, &block)
        value = id.send(name, *args, &block)
        if name == :respond_to? # FIXME
            ::Rails.logger.info " ========> respond_to?(#{args[0]})!"
        else
            ::Rails.logger.info " ========> You may need to define #{name}!"
        end
        value.is_a?(::Integer) ? ::IssueID.new(value, project_key, issue_number) : value
    end

protected

    def to_key_number(key, number)
        "#{key}-#{number}"
    end

end
