require 'sqlite3'
require 'date'

str, t = "", nil
Shoes.app :height => 500, :width => 450 do
  background background("pozadina.jpg")

  begin

    db = SQLite3::Database.open "proba.db"
    db.execute "CREATE TABLE IF NOT EXISTS Proba123(Id INTEGER PRIMARY KEY, Name TEXT ,Text TEXT, Date DATE, Done INTEGER,Important INTEGER)"

  end




  stack :margin => 16 do
    flow {


# Adding items
      btn1 = button '+'

      btn1.click do

        pom = db.execute "SELECT coalesce(max(Id),0) FROM Proba123"
        id = pom[0][0] + 1


        if ("#{t}" == "")
          str = "Please, enter some text!"
          t.replace str

          str = ""

        else
          adding = window title: "Adding", width: 300, height: 200 do
            flow {
              para "Name: "
              @name = edit_line
            }
            flow {
              para "Date:   "
              @date = edit_line
            }
            flow {
              @important=check
              para "Important"
            }
            @btn = button("Add")
            @error = para ""
            @btn.click do
              name = @name.text
              date = @date.text

              v=0

              if(@important.checked)
                v=1
              end
              if(date == '' || name == '')
                @error.text = "Enter all informations!"
              elsif ( date !~ /2[0-9]{3}-(0[0-9]|1[02])-(0[1-9]|[12][0-9]|3[01])/ )
                @error.text = "Format: yyyy-mm-dd"
              elsif (Date.parse(date)<Date.today)
                @error.text = "Please enter another date!"
              else


                list = db.execute "SELECT Name FROM Proba123"
                if (list.include?([name]))
                  @error.text = "Name already exists!"
                else
                  if ( date =~ /2[0-9]{3}-(0[0-9]|1[02])-(0[1-9]|[12][0-9]|3[01])/ )
                    db.execute "INSERT INTO Proba123 VALUES (#{id}, '#{name}', '#{t}', '#{date}', 0, #{v})"
                    id = id + 1
                    str = ""
                    t.replace str
                    adding.close
                  else
                    @error.text = "Format: yyyy-mm-dd"
                  end
                end


              end
            end
          end
        end
        @b.focus
      end

# Listing items
    button("...") do


      str = ""
      t.replace str
      checkmark = "\u2714"
      checkmark1 = "\u2757"
      list = db.execute "SELECT Name,Important,CASE Done WHEN 1 THEN 'Done' ELSE '' END FROM Proba123 ORDER BY Date"
      for i in 0..list.length-1
        if(list[i][2]=='Done')
          str += "#{i+1}. #{list[i][0]} #{checkmark.encode('utf-8')} \n"
        else
          if(list[i][1]==1)
            str += "#{i+1}. #{list[i][0]} #{checkmark1.encode('utf-8')}\n"
          else
            str += "#{i+1}. #{list[i][0]} \n"
          end
        end
      end

      t.replace str
      str = ""
      @b.focus
    end

    button("cl") do
      @b.focus
      str = ""
      t.replace str

    end

# Deleting items
    button("DEL") do

      deleting = window title: "Deleting", width: 300, height: 200 do
        flow {
          para "Name: "
          @name = edit_line
        }

        @btn = button("Del")
        @error = para ""

        @btn.click do
          delName = @name.text

          if(delName == '')
            @error.text = "Enter ID!"
          else
            db.execute "DELETE FROM Proba123 WHERE Name='#{delName}'"
            str = ""
            t.replace str
            deleting.close
          end
        end
      end

      @b.focus
    end

    button("OPEN") do

      opening = window title: "Opening", width: 300, height: 200 do
        flow {
          para "Name: "
          @name1 = edit_line
        }

        @btn = button("Open")
        @error = para ""

        @btn.click do
          opnId = @name1.text
          list1 = db.execute "SELECT Name FROM Proba123 WHERE Name='#{opnId}'"
          if(list1.length>0)
            if(opnId == '')
              @error.text = "Enter Name!"
            else
              str = db.execute "SELECT Text FROM Proba123 WHERE Name='#{opnId}'"
              i=db.execute "SELECT Important FROM Proba123 WHERE Name='#{opnId}'"
              j=db.execute "SELECT Done FROM Proba123 WHERE Name='#{opnId}'"
              t.replace str
              if(j[0][0]==1)
                t.stroke=black
              elsif(i[0][0]==1)
                t.stroke = red
              else
                t.stroke=green
              end
              str = ""
              opening.close

            end
          else
            @error.text = "Name doesn't exists!"
          end
        end

      end
      @b.focus
    end
    button("DONE") do

      done = window title: "Done", width: 300, height: 200 do
        flow {
          para "Name: "
          @name = edit_line
        }
        @btn = button("Done")
        @error = para ""

        @btn.click do
          opnId = @name.text
          list1 = db.execute "SELECT Name FROM Proba123 WHERE Name='#{opnId}'"
          if(list1.length>0)
            if(opnId == '')
              @error.text = "Enter Name!"
            else
              db.execute "UPDATE Proba123 SET Done=1 WHERE Name='#{opnId}'"
              done.close
            end
          else
            @error.text = "Name doesn't exists!"
          end
        end
      end
      @b.focus
    end
  }
  end

  @b=button :width => 0, :height => 0
  stack :margin => 10 do
    t = para "", :font => "Monospace 16px", :stroke => black
    t.cursor = -1
  end


  keypress do |k|
    case k
    when String
      str += k
      t.stroke = black
    when :backspace
      str.slice!(-1)
    when :alt_q
      Shoes.quit
    when :alt_c
      self.clipboard = str
    when :alt_v
      str += self.clipboard
    end
    t.replace str
  end

end
