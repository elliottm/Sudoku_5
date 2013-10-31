require 'sinatra' # load sinatra
require_relative './lib/sudoku'
require_relative './lib/cell.rb'

set :sessions, secret: "i now hate sudoku "
# essentially means sessions = {:current solution => ??, :puzzle => ??, :solution => ??}

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end
# old one:
# get '/' do # default route for our website
#   sudoku = random_sudoku
#   session[:solution] = sudoku
#   @current_solution = puzzle(sudoku)
#   erb :index
# end 

post '/' do
  # The interesting bit here is the transformation of the cell order. 
  # In the HTML, our input fields are laid out box by box, whereas our code 
  # assumes that all cells are ordered row by row. 
  # So we need to transform the order of the cells from the box order to row order. 
  # This method is rather tricky so I added lots of comments to help understand what's going on.
  cells = box_order_to_row_order(params[:cell])  
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end
#relates to above^
# This code saves the current solution to the session (converting the array into a string) 
# and sets the variable session[:check_solution] to true before redirecting to "/" 
# (using a GET method). 
# This way the handler corresponding to the GET request will know to highlight the cells that are incorrect.

get '/solution' do
	@current_solution = session[:solution]
  @solution = @current_solution
  @puzzle = session[:puzzle]
	erb :index
end
#relates to above^
# Now that the solution is saved to the session, 
#we can show it to the player if the user gives up and wants to see it. 
#Let's implement a new route.ß

helpers do
#This method decides whether the cell should have the CSS class 'incorrect', 
#'value-provided' or no special class at all. 
#If this method returns nil, then no class will be used. 
#Finally, we need to define these classes in our CSS file.
  def box_order_to_row_order(cells)
    boxes = cells.each_slice(9).to_a
    (0..8).to_a.inject([]) {|memo, i|
    first_box_index = i / 3 * 3
    three_boxes = boxes[first_box_index, 3]
    three_rows_of_three = three_boxes.map do |box|
      row_number_in_a_box = i % 3
      first_cell_in_the_row_index = row_number_in_a_box * 3
      box[first_cell_in_the_row_index, 3]
    end
    memo += three_rows_of_three.flatten
    }
  end

  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value == 0
    #I needed to change this 0 to "0" otherwise all the cells show up as value provided
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value

    if solution_to_check && 
        must_be_guessed && 
        tried_to_guess && 
        guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value-provided'
    end
  end
end

helpers do
  def cell_value(value)
    value.to_i == 0 ? '' : value
  end
end
# In the session, empty cells are stored as zeros but in the 
# UI they must be displayed as blank cells. 
# Let's add another helper to substitute zeroes with spaces.

#relates to below;
# Since we are now checking the existing solution, we need to save the current 
# solution in the session and display it if it's present. 
# If it's not, we need to generate a new one. 
# This is done by the generate_new_puzzle_if_necessary method.
def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]    
end

#relates to below;
# If the session contains a variable session[:check_variable], 
# then we need to put it in an instance variable, because we'll need to use 
# it in the view to highlight the cells. 
# We set it to nil immediately after we assign the value to the instance 
# variable to prevent the wrong cells from being highlighted if we 
# just refresh the page (this would send a GET request).
def prepare_to_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

def random_sudoku
    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
    # it's obvious there may be no clashes as all numbers are unique
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    # then we solve this (really hard!) sudoku
    sudoku.solve!
    # and give the output to the view as an array of chars
    sudoku.to_s.chars
end

# this method removes some digits from the solution to create a puzzle
def puzzle(sudoku)
  # this method is yours to implement
  puzzle_board = sudoku.dup
  (0..80).to_a.sample(rand(80)).each do |index|
    puzzle_board[index]= 0
  end
  return puzzle_board
 
end

# Consider this example:
# The sessions look very much like a Hash, even though it's not a real Ruby Hash.


# require 'sinatra'
 
# enable :sessions # sessions are disabled by default 
 
# get '/' do
#   # save the current time into session
#   session[:last_visit] = Time.now.to_s 
#   "Last visit time has been recorded"
# end 
 
# get '/last-visit' do
#   # get the last visited time from the session
#   "Previous visit to homepage: #{session[:last_visit]}"
# end

# If you want to delete something from a session, simply set it to nil.

# session[:last_visit] = nil


