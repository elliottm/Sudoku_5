require 'sinatra' # load sinatra
require_relative './lib/sudoku'
require_relative './lib/cell.rb'
require_relative './helpers/application.rb'

set :sessions, secret: "i now hate sudoku "

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]    
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

def random_sudoku
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    sudoku.solve!
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

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

post '/' do
  cells = box_order_to_row_order(params[:cell])  
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  @solution = @current_solution
  @puzzle = session[:puzzle]
  erb :index
end



