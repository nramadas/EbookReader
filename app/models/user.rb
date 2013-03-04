class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # devise :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :book_ownerships
  has_many :books, through: :book_ownerships

  def add_book(file)
    new_book = Book.generate(file)

    books << new_book unless books.index { |book| book.title == new_book.title }
  end

end
