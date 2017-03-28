require 'csv'
require 'erb'

class Person
  attr_reader "name", "phone", "address", "position", "salary", "slack", "github"

  def initialize(name, phone, address, position, salary, slack, github)
    @name = name
    @phone = phone
    @address = address
    @position = position
    @salary = salary
    @slack = slack
    @github = github
  end
end

class TiyDatabase
  attr_reader "profiles"

  def initialize
    @profiles = []
    CSV.foreach("employees.csv", headers: true) do |row|
      name = row["name"]
      phone = row["phone"]
      address = row["address"]
      position = row["position"]
      salary = row["salary"]
      slack = row["slack"]
      github = row["github"]

      person = Person.new(name, phone, address, position, salary.to_i, slack, github)

      @profiles << person
    end
  end

  def initial_question
    puts "(A) Add a profile (S) Search for a profile (D) Delete a profile (E) View employee report save html (H) "
    initial = gets.chomp
  end

  def add_person
    puts "What is your name?"
    name = gets.chomp
    if @profiles.find {|person| person.name == name}
      puts "This profile already exists"
    else
      puts "What is your phone number?"
      phone = gets.chomp.to_i

      puts "What is your address?"
      address = gets.chomp

      puts "What is your position?"
      position = gets.chomp

      puts "What is your salary?"
      salary = gets.chomp.to_i

      puts "what is your Slack Account?"
      slack = gets.chomp

      puts "what is your Git Account?"
      github = gets.chomp

      person = Person.new(name, phone, address, position, salary, slack, github)

      @profiles << person

      employee_save
    end
  end

  def search_person
    puts "Please type in persons name. "
    search_person = gets.chomp
    found_account = @profiles.find { |person| person.name.include?(search_person) || person.slack == search_person || person.github == search_person }
    if found_account
      puts "This is #{found_account.name}'s information.
       \nName: #{found_account.name}
       \nPhone: #{found_account.phone}
       \nAddress: #{found_account.address}
       \nPosition: #{found_account.position}
       \nSalary: #{found_account.salary}
       \nSlack Account: #{found_account.slack}
       \nGitHub Account: #{found_account.github}"
    else
      puts "#{search_person} is not in our system.\n"
    end
  end

  def delete_person
    print "Please type in persons name. "
    delete_name = gets.chomp
    delete_profile = @profiles.delete_if { |person| person.name == delete_name}
    if delete_profile
      puts "profile deleted"
      employee_save
    else
      puts "profile not found"
    end
  end

  def employee_save
    CSV.open("employees.csv", "w") do |csv|
      csv << ["name", "phone", "address", "position", "salary", "slack", "github"]
      @profiles.each do |person|
        csv << [person.name, person.phone, person.address, person.position, person.salary, person.slack, person.github]
      end
    end
  end

  def employee_report
    puts ""
    employee_report
    employees_by_position = @profiles.group_by {|person| person.position}

    employees_by_position.each do |position, people|
      total_salary = people.map {|person| person.salary}.sum
      puts "the total salary of the #{position}s is #{total_salary}"
      puts "the number of #{position}s is #{people.count}"

      tiy_report_html
    end
  end

  def employee_report
    sorted_employee_list = @profiles.sort_by{ |person| person.name}
    puts "Here is a list of everyone we have working here"
    sorted_employee_list.each do |person|
      puts "name: #{person.name.ljust(13)} phone number: #{person.phone.ljust(13)} address: #{person.address.ljust(25)} position: #{person.position.ljust(18)} salary: #{person.salary.to_s.ljust(13)} slack account: #{person.slack.ljust(20)} github account: #{person.github.ljust(20)}"
    end
  end

  def tiy_report_html
    template_string = ERB.new(File.read("TiyReport.html.erb"))
    html = erb_template.result(binding)

    File.write("TiyReport.html", html)

  end

  data = TiyDatabase.new

  loop do
    puts "Add a profile (A), Search (S) or Delete (D) Check the employee report (E) save html (H) "
    selected = gets.chomp.upcase

    data.add_person if selected == 'A'

    data.search_person if selected == 'S'

    data.delete_person if selected == 'D'

    data.employee_report if selected == 'E'

    data.tiy_report_html if selected == 'H'
  end
end
