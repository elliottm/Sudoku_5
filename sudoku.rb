require 'sinatra' # load sinatra
require 'sinatra/partial'
require_relative './lib/sudoku'
require_relative './lib/cell.rb'
require_relative './helpers/application.rb'

set :partial_template_engine, :erb
set :sessions, secret: "i now hate sudoku "

get '/' do
  #route goes through and sets sessions hashes
  #then allocates to instance variables
  #so they can be used by ERB.
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  generate_new_puzzle    
end

def generate_new_puzzle
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

def puzzle(sudoku)
  puzzle_board = sudoku.dup
  (0..80).to_a.sample(rand(80)).each do |index|
    puzzle_board[index]= 0
  end
  return puzzle_board
end

post '/' do
  # puts "Cells: #{params[:cell].inspect}"
  cells = box_order_to_row_order(params[:cell]) #params = essentially received from the internet.  
  # puts "Cells: #{session[:current_solution].inspect}"
  session[:current_solution] = cells.map{|value| value.to_i }.join
  # puts "Cells: #{session[:current_solution].inspect}"
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  @solution = @current_solution #WTF?
  @puzzle = session[:puzzle]
  erb :index
end

get '/new' do
  generate_new_puzzle
  redirect to ('/')
end



