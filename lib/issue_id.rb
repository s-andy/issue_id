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
            id.respond_to?(:to_param) ? id.to_param : id
        end
    end

    def quoted_id
        id.to_i.to_s
    end

    def is_a?(klass)
        klass == ::IssueID || id.is_a?(klass)
    end

    def kind_of?(klass)
        klass == ::IssueID || id.kind_of?(klass)
    end

    def respond_to?(name)
        super || id.respond_to?(name)
    end

    def method_missing(name, *args, &block)
        id.send(name, *args, &block)
    end

protected

    def to_key_number(key, number)
        "#{key}-#{number}"
    end

end
