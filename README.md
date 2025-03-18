# 🏆 Tournament Management System

This is a Tournament Management System built with Ruby on Rails and PostgreSQL. It allows users to create and manage tournaments with role-based authentication and authorization using Pundit and JWT for secure user authentication.

* **Ruby Version:** Ruby 3.4.1
* **Rails Version:** Rails 8.0.1
* **System Dependencies:** PostgreSQL

## 🚀 **Tech Stack**

| Tech             | Description                              |
|------------------|------------------------------------------|
| **Ruby** | Programming language                     |
| **Rails** | Backend framework                        |
| **PostgreSQL** | Database                                  |
| **Pundit** | Authorization                             |
| **JWT** | User authentication                      |
| **Tailwind CSS** | Styling                                  |

## **👤 User Roles**

* **Admin:** Can create and manage all tournaments.
* **Organizer:** Can create and manage their own tournaments.
* **Participant:** Can register for tournaments and view schedules.

## **✨ Features**

✔️ User signup and login with JWT authentication
✔️ Role-based access control with Pundit
✔️ Tournament creation and management
✔️ Registration for tournaments
✔️ Matches creation and management

## **Installation Steps**

1.  **Clone the repository:**
    ```bash
    git clone git@github.com:RushiSelldo/TournamentManagementSystem.git
    cd tournament-management-system
    ```

2.  **Install Bundler (if not already installed):**
    ```bash
    gem install bundler
    ```

3.  **Install Dependencies:**
    ```bash
    bundle install
    ```

4.  **Set Up Database:**
    ```bash
    rails db:migrate
    ```

5.  **Start the server:**
    ```bash
    rails server
    ```

6.  **Run the application:**
    Open your web browser and navigate to `http://localhost:3000`.



