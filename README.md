# Cryptr with Rails API

## 04 - Protect API Endpoints

### Include the secured concern and the options method

The protected endpoints need to include the `secured` concern and the `options` method (which handles `CORS` from the client App).

🛠️️ Open up `app/controllers/api_v1_controller.rb` and add `include Secured`:

```ruby
class ApiV1Controller < ApplicationController
  # 1. Add Secured concern
  include Secured
  before_action :set_access_control_headers

  def index
    render json: [
      {
        "id" => 1,
        "user_id" =>
        "eba25511-afce-4c8e-8cab-f82822434648",
        "title" => "learn git",
        "tags" => ["colaborate", "git" ,"cli", "commit", "versionning"],
        "img" => "https://carlchenet.com/wp-content/uploads/2019/04/git-logo.png",
        "desc" => "Learn how to create, manage, fork, and collaborate on a project. Git stays a major part of all companies projects. Learning git is learning how to make your project better everyday",
        "date" => '5 Nov',
        "timestamp" => 1604577600000,
        "teacher" => {
            "name" => "Max",
            "picture" => "https://images.unsplash.com/photo-1558531304-a4773b7e3a9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80"
        }
      }
    ]
  end
# ...
```

🛠️️ Now, add the `options` method:

```ruby
class ApiV1Controller < ApplicationController

  include Secured
  before_action :set_access_control_headers

  def index
    render json: [
      {
        "id" => 1,
        "user_id" =>
        "eba25511-afce-4c8e-8cab-f82822434648",
        "title" => "learn git",
        "tags" => ["colaborate", "git" ,"cli", "commit", "versionning"],
        "img" => "https://carlchenet.com/wp-content/uploads/2019/04/git-logo.png",
        "desc" => "Learn how to create, manage, fork, and collaborate on a project. Git stays a major part of all companies projects. Learning git is learning how to make your project better everyday",
        "date" => '5 Nov',
        "timestamp" => 1604577600000,
        "teacher" => {
            "name" => "Max",
            "picture" => "https://images.unsplash.com/photo-1558531304-a4773b7e3a9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80"
        }
      }
    ]
  end

  # 2. Add options method
  def options
  Rails.logger.info "option request"
    if ENV['CRYPTR_AUDIENCE'] == request.env['HTTP_ORIGIN']
      :ok
    else
      :forbidden
    end
  end
  
  private
  
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = ENV['CRYPTR_AUDIENCE']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
  end
end
```

### Test with a Cryptr Vue app

It is now time to try this on an application. For this purpose, we have an example app on Vue.

🛠 Run your code with `rails s`

🛠 Clone our `cryptr-vue-sample`:

```bash
git clone --branch 07-backend-courses-api https://github.com/cryptr-examples/cryptr-vue2-sample.git
```

🛠 Install the Vue project dependencies with `yarn`

🛠️️  Create the `.env.local` file and add your variables. Don't forget to replace `YOUR_CLIENT_ID` & `YOUR_DOMAIN`:

```typescript
VUE_APP_AUDIENCE=http://localhost:8080
VUE_APP_CLIENT_ID=YOUR_CLIENT_ID
VUE_APP_DEFAULT_LOCALE=fr
VUE_APP_DEFAULT_REDIRECT_URI=http://localhost:8080
VUE_APP_TENANT_DOMAIN=YOUR_DOMAIN
VUE_APP_CRYPTR_TELEMETRY=FALSE
```

🛠️️ Open up the Profile Component in `src/views/Profile.vue` and modify the url request:

```typescript
<script>
  import { getCryptrClient } from "../CryptrPlugin";
    export default {
    data() {
      return {
        courses: [],
        errors: [],
      };
    },
    created() {
      const client = getCryptrClient();
      console.log("created");
      client
        .decoratedRequest({
          method: "GET",
          // url: "http://localhost/api/v1/courses
          // Add port 3000 for rails:
          url: "http://localhost:3000/api/v1/courses",
        })
        .then((data) => {
          console.log(data);
          this.courses = data.data;
        })
        .catch((error) => {
          console.error(error);
          this.errors = [error];
        });
    },
  };
</script>
```

🛠️️ Run the vue server with `yarn serve` and try to connect. Your Vue application redirects you to your sign form page, where you can sign in or sign up with an email.

__NOTE: You can log in with a sandbox email and we send you a magic link which should directly arrive in your personal inbox.__

Once you're connected, click on "Protected route". You can now view the list of courses.

It’s done, congratulations if you made it to the end!

I hope this was helpful, and thanks for reading! 🙂
