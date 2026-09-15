require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "OpenEWS API Documentation"
  config.api_explanation = <<~HEREDOC
    # Introduction

    The OpenEWS API enables Organizations and Governments to efficiently manage and disseminate early warning broadcasts to beneficiaries in disaster-prone areas.
    It provides robust tools for interacting with beneficiary data, crafting broadcast notification messages, and monitoring the performance of dissemination broadcasts. Built with scalability and flexibility in mind, OpenEWS supports integration with external systems, ensuring seamless communication and data interoperability.

    The API follows the [JSON:API standard](https://jsonapi.org/), a specification for building APIs in a consistent and predictable manner. This ensures standardization in resource representation, error handling, and query parameters, making integration and development easier for your technical team.

    This documentation is intended for developers, system integrators, and technical stakeholders working on early warning systems. By leveraging the OpenEWS API, you can automate processes such as beneficiary management, broadcast distribution, and reporting, empowering your organization to deliver timely and impactful alerts.

    ## Making an HTTP Request

    All API endpoints are accessible via HTTPS and adhere to RESTful principles. The API uses the [JSON:API standard](https://jsonapi.org/), meaning all requests and responses conform to a defined structure, including the use of specific top-level document fields (`data`, `attributes`, `relationships`, etc.).

    The base URL for the API is:
    `https://api.open-ews.org/v1/`

    Requests should include the following components:

    1. **HTTP Method:** The API supports standard methods such as `GET`, `POST`, `PATCH`, and `DELETE`. Use the appropriate method based on the endpoint requirements.
    2. **Headers:** Ensure the request includes the `Authorization` header with a valid API token and the `Content-Type` header set to `application/vnd.api+json` to comply with JSON:API standards.
    3. **Endpoint URL:** Combine the base URL with the specific endpoint path to form the complete request URL.

    ### Example HTTP Request

    ```http
    POST https://api.open-ews.org/v1/beneficiaries
    Authorization: Bearer YOUR_API_TOKEN
    Content-Type: application/vnd.api+json
    ```

    ```json
    {
      "data": {
        "type": "beneficiary",
        "attributes": {
          "phone_number": "+85510999999",
          "gender": "M",
          "iso_country_code": "KH"
        }
      }
    }
    ```

    ## Credentials

    To access the OpenEWS API, you need an API token. Tokens authenticate your application and authorize access to API resources. Follow these steps to obtain and manage your API credentials:

    1. **Request an API Token:** Log in to your OpenEWS account or contact your administrator to generate an API token.
    2. **Include the Token in Requests:** Pass the token in the `Authorization` header of each API request using the format `Bearer YOUR_API_TOKEN`.
    3. **Token Security:** Treat your token as sensitive information. Do not expose it in client-side code or share it publicly.
    4. **Regenerate or Revoke Tokens:** If your token is compromised or needs to be updated, regenerate it from your account settings or by contacting the administrator.

    ### Example Authorization Header

    `Authorization: Bearer YOUR_API_TOKEN`

    ## Webhooks

    OpenEWS uses webhooks to notify your application when events occur in your account.

    To help ensure that webhook requests originate from OpenEWS, every webhook delivery is signed and includes a JWT in the `Authorization` header. You should verify this signature before processing the event to confirm that the request was sent by OpenEWS and has not been tampered with.

    ### Verifying webhook signatures

    Webhook requests use standard Bearer authentication with a signed [JSON Web Token (JWT)](https://jwt.io/). Tokens are signed using the HS256 (HMAC-SHA256) algorithm and your webhook signing secret.

    When a webhook is received, validate the JWT using your signing secret and verify that the issuer (`iss`) claim is set to `OpenEWS`.

    Example in Ruby:

    ```ruby
    JWT.decode(
      request.headers["Authorization"].sub("Bearer ", ""),
      "[your-webhook-signing-secret]",
      true,
      algorithm: "HS256",
      verify_iss: true,
      iss: "OpenEWS"
    )
    ```

    If token verification fails, the webhook request should be rejected.

    ### Event payloads

    The payload delivered by a webhook is identical to the corresponding event object returned by the Events API. See the [Events documentation](#events) for the complete event schema and examples for each event type.

    ## Filtering

    OpenEWS supports filtering of resources using query parameters. Filters are passed using the following format:

    ```http
    ?filter[$attribute][$operator]=value
    ```

    You can combine multiple filters by adding additional `filter[...]` query parameters.

    Filtering operators vary depending on the attribute type.

    ### String Type Operators

    For attributes of type **string**, the following operators are supported:

    | Operator       | Description                                      |
    |----------------|--------------------------------------------------|
    | `eq`           | Equals the specified value                       |
    | `not_eq`       | Does not equal the specified value               |
    | `contains`     | Contains the specified substring                 |
    | `not_contains` | Does not contain the specified substring         |
    | `starts_with`  | Starts with the specified substring              |
    | `in`           | Matches any of the specified values (array)      |
    | `not_in`       | Does not match any of the specified values       |
    | `is_null`      | Checks if the value is null (`true` or `false`)  |

    **Examples:**

    ```http
    GET https://api.open-ews.org/v1/beneficiaries?filter[phone_number][starts_with]=855
    GET https://api.open-ews.org/v1/beneficiaries?filter[gender][in][]=M&filter[gender][in][]=F
    GET https://api.open-ews.org/v1/beneficiaries?filter[gender][is_null]=true
    ```

    ### Value Type Operators (e.g., integers, floats, dates)

    Use these for numeric or comparable types (e.g., `created_at`):

    | Operator   | Description                                          |
    |------------|------------------------------------------------------|
    | `eq`       | Equals the specified value                           |
    | `not_eq`   | Does not equal the specified value                   |
    | `gt`       | Greater than the specified value                     |
    | `gteq`     | Greater than or equal to the specified value         |
    | `lt`       | Less than the specified value                        |
    | `lteq`     | Less than or equal to the specified value            |
    | `between`  | Between two values (inclusive), passed as an array   |
    | `is_null`  | Checks if the value is null (`true` or `false`)      |

    **Examples:**

    ```http
    GET https://api.open-ews.org/v1/beneficiaries?filter[created_at][between][]=2025-04-01&filter[created_at][between][]=2025-04-30
    GET https://api.open-ews.org/v1/beneficiaries?filter[created_at][gteq]=2025-04-01
    ```

    ### Array Type Operators

    For attributes of type **array**, the following operators are supported:

    | Operator   | Description                                                             |
    | ---------- | ----------------------------------------------------------------------- |
    | `eq`       | Matches resources where the array contains exactly the specified values |
    | `contains` | Matches resources where the array contains any of the specified values  |

    **Examples:**

    ```http
    GET https://api.open-ews.org/v1/broadcasts?filter[channels][eq][]=audio&filter[channels][eq][]=text_message
    GET https://api.open-ews.org/v1/broadcasts?filter[channels][contains][]=voice_call
    ```
  HEREDOC

  config.format = :open_ews_slate
  config.curl_headers_to_filter = [ "Host", "Cookie", "Content-Type" ]

  config.request_headers_to_include = []
  config.response_headers_to_include = [ "Location", "Per-Page", "Total" ]
  config.request_body_formatter = proc do |params|
    JSON.pretty_generate(params) if params.present?
  end
  config.keep_source_order = true
  config.disable_dsl_status!

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end
end
