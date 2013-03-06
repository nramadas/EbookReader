class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2, :dropbox]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :provider, :uid, :dropbox_token, :dropbox_secret

  has_many :book_ownerships
  has_many :books, through: :book_ownerships

  def self.find_for_omniauth(auth)
    user = User.find_by_email(auth.info.email)

    if user
      user.update_attributes!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )

    else
      user = User.create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )

      # user.skip_confirmation!
      # user.send_reset_passoword_instructions
    end

    user
  end

  def self.find_for_google_oauth(auth)
    find_for_omniauth(auth)
  end

  def self.find_for_dropbox_oauth(auth)
    user = find_for_omniauth(auth)

    user.update_attributes!(
      dropbox_token: auth.extra.access_token.token,
      dropbox_secret: auth.extra.access_token.secret
    )

    user
  end

  def add_book(file)
    new_book = Book.generate(file)

    books << new_book unless books.index { |book| book.title == new_book.title }

    new_book
  end

end
