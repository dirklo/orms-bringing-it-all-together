class Dog 
    attr_accessor :name, :breed, :id

    def initialize(attributes, id = nil)
        @name = attributes[:name]
        @breed = attributes[:breed]
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        if !!self.id
            self.update
        else
            self.insert
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;").flatten.first
        end
        self
    end

    def insert
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?);
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?
            WHERE dogs.id = ?; 
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)   
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new({:name=>row[1], :breed=>row[2]}, row[0])
    end

    def self.find_by_id(id)
        Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).flatten)
    end

    def self.find_by_name(name)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).flatten)
    end


    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND BREED = ?;
        SQL

        dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).flatten

        if dog == []
            create(attributes)
        else
            new_from_db(dog)
        end
    end
end
