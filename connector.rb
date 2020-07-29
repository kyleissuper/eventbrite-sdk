{
  title: "Eventbrite",
  connection: {
    fields: [
      {
        name: "private_token",
        hint: "https://www.eventbrite.com/account-settings/apps",
        control_type: "password",
        optional: false
      }
    ],
    authorization: {
      type: "custom_auth",
      apply: lambda do |connection|
        headers("Authorization": "Bearer #{connection["private_token"]}")
      end
    }
  },
  test: lambda do |_connection|
    get("https://www.eventbriteapi.com/v3/users/me/")
  end,
  triggers: {
    new_or_updated_attendee: {
      help: "Provide either Event ID or Organization ID. 'Since' is optional",
      input_fields: lambda do
        [
          { name: "event_id" },
          { name: "organization_id", control_type: "select", pick_list: "orgs" },
          { name: "since", type: "timestamp" }
        ]
      end,
      poll: lambda do |connection, input, last_updated_since|
        if input["event_id"].present?
          url = "https://www.eventbriteapi.com/v3/events/#{input["event_id"]}/attendees/"
        else
          url = "https://www.eventbriteapi.com/v3/organizations/#{input["organization_id"]}/attendees/"
        end
        changed_since = (last_updated_since || input['since'] || 100.years.ago).to_time.utc.iso8601
        response = get(url).
          params(changed_since: changed_since)
        next_updated_since = response["attendees"].last['changed'] unless response["attendees"].length == 0
        {
          events: response["attendees"],
          next_poll: next_updated_since,
          can_poll_more: response["pagination"]["has_more_items"]
        }
      end,
      dedup: lambda do |event|
        event["id"]
      end,
      output_fields: lambda do |object_definitions|
        object_definitions["attendee"]
      end
    }
  },
  object_definitions: {
    attendee: {
      fields: lambda do
        [
           {
             "control_type": "text",
             "label": "ID",
             "type": "string",
             "name": "id"
           },
           {
             "control_type": "text",
             "label": "Created",
             "render_input": "date_time_conversion",
             "parse_output": "date_time_conversion",
             "type": "date_time",
             "name": "created"
           },
           {
             "control_type": "text",
             "label": "Changed",
             "render_input": "date_time_conversion",
             "parse_output": "date_time_conversion",
             "type": "date_time",
             "name": "changed"
           },
           {
             "control_type": "text",
             "label": "Ticket class ID",
             "type": "string",
             "name": "ticket_class_id"
           },
           {
             "control_type": "text",
             "label": "Ticket class name",
             "type": "string",
             "name": "ticket_class_name"
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "Name",
                 "type": "string",
                 "name": "name"
               },
               {
                 "control_type": "text",
                 "label": "Email",
                 "type": "string",
                 "name": "email"
               },
               {
                 "control_type": "text",
                 "label": "First name",
                 "type": "string",
                 "name": "first_name"
               },
               {
                 "control_type": "text",
                 "label": "Last name",
                 "type": "string",
                 "name": "last_name"
               },
               {
                 "control_type": "text",
                 "label": "Prefix",
                 "type": "string",
                 "name": "prefix"
               },
               {
                 "control_type": "text",
                 "label": "Suffix",
                 "type": "string",
                 "name": "suffix"
               },
               {
                 "control_type": "number",
                 "label": "Age",
                 "parse_output": "float_conversion",
                 "type": "number",
                 "name": "age"
               },
               {
                 "control_type": "text",
                 "label": "Job title",
                 "type": "string",
                 "name": "job_title"
               },
               {
                 "control_type": "text",
                 "label": "Company",
                 "type": "string",
                 "name": "company"
               },
               {
                 "control_type": "text",
                 "label": "Website",
                 "type": "string",
                 "name": "website"
               },
               {
                 "control_type": "text",
                 "label": "Blog",
                 "type": "string",
                 "name": "blog"
               },
               {
                 "control_type": "text",
                 "label": "Gender",
                 "type": "string",
                 "name": "gender"
               },
               {
                 "control_type": "text",
                 "label": "Birth date",
                 "type": "string",
                 "name": "birth_date"
               },
               {
                 "control_type": "text",
                 "label": "Cell phone",
                 "type": "string",
                 "name": "cell_phone"
               },
               {
                 "control_type": "text",
                 "label": "Work phone",
                 "type": "string",
                 "name": "work_phone"
               },
               {
                 "properties": [
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Address 1",
                         "type": "string",
                         "name": "address_1"
                       },
                       {
                         "control_type": "text",
                         "label": "Address 2",
                         "type": "string",
                         "name": "address_2"
                       },
                       {
                         "control_type": "text",
                         "label": "City",
                         "type": "string",
                         "name": "city"
                       },
                       {
                         "control_type": "text",
                         "label": "Region",
                         "type": "string",
                         "name": "region"
                       },
                       {
                         "control_type": "text",
                         "label": "Postal code",
                         "type": "string",
                         "name": "postal_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Country",
                         "type": "string",
                         "name": "country"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized address display",
                         "type": "string",
                         "name": "localized_address_display"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized area display",
                         "type": "string",
                         "name": "localized_area_display"
                       }
                     ],
                     "label": "Home",
                     "type": "object",
                     "name": "home"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Address 1",
                         "type": "string",
                         "name": "address_1"
                       },
                       {
                         "control_type": "text",
                         "label": "Address 2",
                         "type": "string",
                         "name": "address_2"
                       },
                       {
                         "control_type": "text",
                         "label": "City",
                         "type": "string",
                         "name": "city"
                       },
                       {
                         "control_type": "text",
                         "label": "Region",
                         "type": "string",
                         "name": "region"
                       },
                       {
                         "control_type": "text",
                         "label": "Postal code",
                         "type": "string",
                         "name": "postal_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Country",
                         "type": "string",
                         "name": "country"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized address display",
                         "type": "string",
                         "name": "localized_address_display"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized area display",
                         "type": "string",
                         "name": "localized_area_display"
                       }
                     ],
                     "label": "Ship",
                     "type": "object",
                     "name": "ship"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Address 1",
                         "type": "string",
                         "name": "address_1"
                       },
                       {
                         "control_type": "text",
                         "label": "Address 2",
                         "type": "string",
                         "name": "address_2"
                       },
                       {
                         "control_type": "text",
                         "label": "City",
                         "type": "string",
                         "name": "city"
                       },
                       {
                         "control_type": "text",
                         "label": "Region",
                         "type": "string",
                         "name": "region"
                       },
                       {
                         "control_type": "text",
                         "label": "Postal code",
                         "type": "string",
                         "name": "postal_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Country",
                         "type": "string",
                         "name": "country"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized address display",
                         "type": "string",
                         "name": "localized_address_display"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized area display",
                         "type": "string",
                         "name": "localized_area_display"
                       }
                     ],
                     "label": "Work",
                     "type": "object",
                     "name": "work"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Address 1",
                         "type": "string",
                         "name": "address_1"
                       },
                       {
                         "control_type": "text",
                         "label": "Address 2",
                         "type": "string",
                         "name": "address_2"
                       },
                       {
                         "control_type": "text",
                         "label": "City",
                         "type": "string",
                         "name": "city"
                       },
                       {
                         "control_type": "text",
                         "label": "Region",
                         "type": "string",
                         "name": "region"
                       },
                       {
                         "control_type": "text",
                         "label": "Postal code",
                         "type": "string",
                         "name": "postal_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Country",
                         "type": "string",
                         "name": "country"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized address display",
                         "type": "string",
                         "name": "localized_address_display"
                       },
                       {
                         "control_type": "text",
                         "label": "Localized area display",
                         "type": "string",
                         "name": "localized_area_display"
                       }
                     ],
                     "label": "Bill",
                     "type": "object",
                     "name": "bill"
                   }
                 ],
                 "label": "Addresses",
                 "type": "object",
                 "name": "addresses"
               }
             ],
             "label": "Profile",
             "type": "object",
             "name": "profile"
           },
           {
             "name": "questions",
             "type": "array",
             "of": "object",
             "label": "Questions",
             "properties": [
               {
                 "control_type": "text",
                 "label": "ID",
                 "type": "string",
                 "name": "id"
               },
               {
                 "control_type": "text",
                 "label": "Label",
                 "type": "string",
                 "name": "label"
               },
               {
                 "control_type": "text",
                 "label": "Type",
                 "type": "string",
                 "name": "type"
               },
               {
                 "control_type": "text",
                 "label": "Required",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Required",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "required"
                 },
                 "type": "boolean",
                 "name": "required"
               }
             ]
           },
           {
             "name": "answers",
             "type": "array",
             "of": "object",
             "label": "Answers",
             "properties": [
               {
                 "control_type": "text",
                 "label": "Question ID",
                 "type": "string",
                 "name": "question_id"
               },
               {
                 "control_type": "text",
                 "label": "Attendee ID",
                 "type": "string",
                 "name": "attendee_id"
               },
               {
                 "control_type": "text",
                 "label": "Question",
                 "type": "string",
                 "name": "question"
               },
               {
                 "control_type": "text",
                 "label": "Type",
                 "type": "string",
                 "name": "type"
               },
               {
                 "control_type": "text",
                 "label": "Answer",
                 "type": "string",
                 "name": "answer"
               }
             ]
           },
           {
             "name": "barcodes",
             "type": "array",
             "of": "object",
             "label": "Barcodes",
             "properties": [
               {
                 "control_type": "text",
                 "label": "Barcode",
                 "type": "string",
                 "name": "barcode"
               },
               {
                 "control_type": "text",
                 "label": "Status",
                 "type": "string",
                 "name": "status"
               },
               {
                 "control_type": "text",
                 "label": "Created",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "created"
               },
               {
                 "control_type": "text",
                 "label": "Changed",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "changed"
               },
               {
                 "control_type": "number",
                 "label": "Checkin type",
                 "parse_output": "float_conversion",
                 "type": "number",
                 "name": "checkin_type"
               },
               {
                 "control_type": "text",
                 "label": "Is printed",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is printed",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_printed"
                 },
                 "type": "boolean",
                 "name": "is_printed"
               }
             ]
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "ID",
                 "type": "string",
                 "name": "id"
               },
               {
                 "control_type": "text",
                 "label": "Name",
                 "type": "string",
                 "name": "name"
               },
               {
                 "control_type": "text",
                 "label": "Date joined",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "date_joined"
               },
               {
                 "control_type": "text",
                 "label": "Event ID",
                 "type": "string",
                 "name": "event_id"
               }
             ],
             "label": "Team",
             "type": "object",
             "name": "team"
           },
           {
             "control_type": "text",
             "label": "Affiliate",
             "type": "string",
             "name": "affiliate"
           },
           {
             "control_type": "text",
             "label": "Checked in",
             "render_input": {},
             "parse_output": {},
             "toggle_hint": "Select from option list",
             "toggle_field": {
               "label": "Checked in",
               "control_type": "text",
               "toggle_hint": "Use custom value",
               "type": "boolean",
               "name": "checked_in"
             },
             "type": "boolean",
             "name": "checked_in"
           },
           {
             "control_type": "text",
             "label": "Cancelled",
             "render_input": {},
             "parse_output": {},
             "toggle_hint": "Select from option list",
             "toggle_field": {
               "label": "Cancelled",
               "control_type": "text",
               "toggle_hint": "Use custom value",
               "type": "boolean",
               "name": "cancelled"
             },
             "type": "boolean",
             "name": "cancelled"
           },
           {
             "control_type": "text",
             "label": "Refunded",
             "render_input": {},
             "parse_output": {},
             "toggle_hint": "Select from option list",
             "toggle_field": {
               "label": "Refunded",
               "control_type": "text",
               "toggle_hint": "Use custom value",
               "type": "boolean",
               "name": "refunded"
             },
             "type": "boolean",
             "name": "refunded"
           },
           {
             "properties": [
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "number",
                     "label": "Value",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "value"
                   },
                   {
                     "control_type": "text",
                     "label": "Major value",
                     "type": "string",
                     "name": "major_value"
                   },
                   {
                     "control_type": "text",
                     "label": "Display",
                     "type": "string",
                     "name": "display"
                   }
                 ],
                 "label": "Base price",
                 "type": "object",
                 "name": "base_price"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "number",
                     "label": "Value",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "value"
                   },
                   {
                     "control_type": "text",
                     "label": "Major value",
                     "type": "string",
                     "name": "major_value"
                   },
                   {
                     "control_type": "text",
                     "label": "Display",
                     "type": "string",
                     "name": "display"
                   }
                 ],
                 "label": "Gross",
                 "type": "object",
                 "name": "gross"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "number",
                     "label": "Value",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "value"
                   },
                   {
                     "control_type": "text",
                     "label": "Major value",
                     "type": "string",
                     "name": "major_value"
                   },
                   {
                     "control_type": "text",
                     "label": "Display",
                     "type": "string",
                     "name": "display"
                   }
                 ],
                 "label": "Eventbrite fee",
                 "type": "object",
                 "name": "eventbrite_fee"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "number",
                     "label": "Value",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "value"
                   },
                   {
                     "control_type": "text",
                     "label": "Major value",
                     "type": "string",
                     "name": "major_value"
                   },
                   {
                     "control_type": "text",
                     "label": "Display",
                     "type": "string",
                     "name": "display"
                   }
                 ],
                 "label": "Payment fee",
                 "type": "object",
                 "name": "payment_fee"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "number",
                     "label": "Value",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "value"
                   },
                   {
                     "control_type": "text",
                     "label": "Major value",
                     "type": "string",
                     "name": "major_value"
                   },
                   {
                     "control_type": "text",
                     "label": "Display",
                     "type": "string",
                     "name": "display"
                   }
                 ],
                 "label": "Tax",
                 "type": "object",
                 "name": "tax"
               }
             ],
             "label": "Costs",
             "type": "object",
             "name": "costs"
           },
           {
             "control_type": "text",
             "label": "Status",
             "type": "string",
             "name": "status"
           },
           {
             "control_type": "text",
             "label": "Event ID",
             "type": "string",
             "name": "event_id"
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "ID",
                 "type": "string",
                 "name": "id"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Text",
                     "type": "string",
                     "name": "text"
                   },
                   {
                     "control_type": "text",
                     "label": "Html",
                     "type": "string",
                     "name": "html"
                   }
                 ],
                 "label": "Name",
                 "type": "object",
                 "name": "name"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Text",
                     "type": "string",
                     "name": "text"
                   },
                   {
                     "control_type": "text",
                     "label": "Html",
                     "type": "string",
                     "name": "html"
                   }
                 ],
                 "label": "Description",
                 "type": "object",
                 "name": "description"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Timezone",
                     "type": "string",
                     "name": "timezone"
                   },
                   {
                     "control_type": "text",
                     "label": "Utc",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "utc"
                   },
                   {
                     "control_type": "text",
                     "label": "Local",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "local"
                   }
                 ],
                 "label": "Start",
                 "type": "object",
                 "name": "start"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Timezone",
                     "type": "string",
                     "name": "timezone"
                   },
                   {
                     "control_type": "text",
                     "label": "Utc",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "utc"
                   },
                   {
                     "control_type": "text",
                     "label": "Local",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "local"
                   }
                 ],
                 "label": "End",
                 "type": "object",
                 "name": "end"
               },
               {
                 "control_type": "text",
                 "label": "URL",
                 "type": "string",
                 "name": "url"
               },
               {
                 "control_type": "text",
                 "label": "Vanity URL",
                 "type": "string",
                 "name": "vanity_url"
               },
               {
                 "control_type": "text",
                 "label": "Created",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "created"
               },
               {
                 "control_type": "text",
                 "label": "Changed",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "changed"
               },
               {
                 "control_type": "text",
                 "label": "Published",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "published"
               },
               {
                 "control_type": "text",
                 "label": "Status",
                 "type": "string",
                 "name": "status"
               },
               {
                 "control_type": "text",
                 "label": "Currency",
                 "type": "string",
                 "name": "currency"
               },
               {
                 "control_type": "text",
                 "label": "Online event",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Online event",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "online_event"
                 },
                 "type": "boolean",
                 "name": "online_event"
               },
               {
                 "control_type": "text",
                 "label": "Organization ID",
                 "type": "string",
                 "name": "organization_id"
               },
               {
                 "control_type": "text",
                 "label": "Organizer ID",
                 "type": "string",
                 "name": "organizer_id"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Name",
                     "type": "string",
                     "name": "name"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Description",
                     "type": "object",
                     "name": "description"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Long description",
                     "type": "object",
                     "name": "long_description"
                   },
                   {
                     "control_type": "text",
                     "label": "Logo ID",
                     "type": "string",
                     "name": "logo_id"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "URL",
                         "type": "string",
                         "name": "url"
                       },
                       {
                         "properties": [
                           {
                             "properties": [
                               {
                                 "control_type": "number",
                                 "label": "Y",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "y"
                               },
                               {
                                 "control_type": "number",
                                 "label": "X",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "x"
                               }
                             ],
                             "label": "Top left",
                             "type": "object",
                             "name": "top_left"
                           },
                           {
                             "control_type": "number",
                             "label": "Width",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "width"
                           },
                           {
                             "control_type": "number",
                             "label": "Height",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "height"
                           }
                         ],
                         "label": "Crop mask",
                         "type": "object",
                         "name": "crop_mask"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "URL",
                             "type": "string",
                             "name": "url"
                           },
                           {
                             "control_type": "number",
                             "label": "Width",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "width"
                           },
                           {
                             "control_type": "number",
                             "label": "Height",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "height"
                           }
                         ],
                         "label": "Original",
                         "type": "object",
                         "name": "original"
                       },
                       {
                         "control_type": "text",
                         "label": "Aspect ratio",
                         "type": "string",
                         "name": "aspect_ratio"
                       },
                       {
                         "control_type": "text",
                         "label": "Edge color",
                         "type": "string",
                         "name": "edge_color"
                       },
                       {
                         "control_type": "text",
                         "label": "Edge color set",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Edge color set",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "edge_color_set"
                         },
                         "type": "boolean",
                         "name": "edge_color_set"
                       }
                     ],
                     "label": "Logo",
                     "type": "object",
                     "name": "logo"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   },
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "URL",
                     "type": "string",
                     "name": "url"
                   },
                   {
                     "control_type": "number",
                     "label": "Num past events",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "num_past_events"
                   },
                   {
                     "control_type": "number",
                     "label": "Num future events",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "num_future_events"
                   },
                   {
                     "control_type": "text",
                     "label": "Twitter",
                     "type": "string",
                     "name": "twitter"
                   },
                   {
                     "control_type": "text",
                     "label": "Facebook",
                     "type": "string",
                     "name": "facebook"
                   }
                 ],
                 "label": "Organizer",
                 "type": "object",
                 "name": "organizer"
               },
               {
                 "control_type": "text",
                 "label": "Logo ID",
                 "type": "string",
                 "name": "logo_id"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "URL",
                     "type": "string",
                     "name": "url"
                   },
                   {
                     "properties": [
                       {
                         "properties": [
                           {
                             "control_type": "number",
                             "label": "Y",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "y"
                           },
                           {
                             "control_type": "number",
                             "label": "X",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "x"
                           }
                         ],
                         "label": "Top left",
                         "type": "object",
                         "name": "top_left"
                       },
                       {
                         "control_type": "number",
                         "label": "Width",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "width"
                       },
                       {
                         "control_type": "number",
                         "label": "Height",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "height"
                       }
                     ],
                     "label": "Crop mask",
                     "type": "object",
                     "name": "crop_mask"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "URL",
                         "type": "string",
                         "name": "url"
                       },
                       {
                         "control_type": "number",
                         "label": "Width",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "width"
                       },
                       {
                         "control_type": "number",
                         "label": "Height",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "height"
                       }
                     ],
                     "label": "Original",
                     "type": "object",
                     "name": "original"
                   },
                   {
                     "control_type": "text",
                     "label": "Aspect ratio",
                     "type": "string",
                     "name": "aspect_ratio"
                   },
                   {
                     "control_type": "text",
                     "label": "Edge color",
                     "type": "string",
                     "name": "edge_color"
                   },
                   {
                     "control_type": "text",
                     "label": "Edge color set",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Edge color set",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "edge_color_set"
                     },
                     "type": "boolean",
                     "name": "edge_color_set"
                   }
                 ],
                 "label": "Logo",
                 "type": "object",
                 "name": "logo"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Name",
                     "type": "string",
                     "name": "name"
                   },
                   {
                     "control_type": "text",
                     "label": "Age restriction",
                     "type": "string",
                     "name": "age_restriction"
                   },
                   {
                     "control_type": "number",
                     "label": "Capacity",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "capacity"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Address 1",
                         "type": "string",
                         "name": "address_1"
                       },
                       {
                         "control_type": "text",
                         "label": "Address 2",
                         "type": "string",
                         "name": "address_2"
                       },
                       {
                         "control_type": "text",
                         "label": "City",
                         "type": "string",
                         "name": "city"
                       },
                       {
                         "control_type": "text",
                         "label": "Region",
                         "type": "string",
                         "name": "region"
                       },
                       {
                         "control_type": "text",
                         "label": "Postal code",
                         "type": "string",
                         "name": "postal_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Country",
                         "type": "string",
                         "name": "country"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       }
                     ],
                     "label": "Address",
                     "type": "object",
                     "name": "address"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   },
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "Latitude",
                     "type": "string",
                     "name": "latitude"
                   },
                   {
                     "control_type": "text",
                     "label": "Longitude",
                     "type": "string",
                     "name": "longitude"
                   }
                 ],
                 "label": "Venue",
                 "type": "object",
                 "name": "venue"
               },
               {
                 "control_type": "text",
                 "label": "Format ID",
                 "type": "string",
                 "name": "format_id"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "Name",
                     "type": "string",
                     "name": "name"
                   },
                   {
                     "control_type": "text",
                     "label": "Name localized",
                     "type": "string",
                     "name": "name_localized"
                   },
                   {
                     "control_type": "text",
                     "label": "Short name",
                     "type": "string",
                     "name": "short_name"
                   },
                   {
                     "control_type": "text",
                     "label": "Short name localized",
                     "type": "string",
                     "name": "short_name_localized"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   }
                 ],
                 "label": "Format",
                 "type": "object",
                 "name": "format"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   },
                   {
                     "control_type": "text",
                     "label": "Name",
                     "type": "string",
                     "name": "name"
                   },
                   {
                     "control_type": "text",
                     "label": "Name localized",
                     "type": "string",
                     "name": "name_localized"
                   },
                   {
                     "control_type": "text",
                     "label": "Short name",
                     "type": "string",
                     "name": "short_name"
                   },
                   {
                     "control_type": "text",
                     "label": "Short name localized",
                     "type": "string",
                     "name": "short_name_localized"
                   },
                   {
                     "name": "subcategories",
                     "type": "array",
                     "of": "object",
                     "label": "Subcategories",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "properties": [],
                         "label": "Parent category",
                         "type": "object",
                         "name": "parent_category"
                       }
                     ]
                   }
                 ],
                 "label": "Category",
                 "type": "object",
                 "name": "category"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   },
                   {
                     "control_type": "text",
                     "label": "Name",
                     "type": "string",
                     "name": "name"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Name localized",
                         "type": "string",
                         "name": "name_localized"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name",
                         "type": "string",
                         "name": "short_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name localized",
                         "type": "string",
                         "name": "short_name_localized"
                       }
                     ],
                     "label": "Parent category",
                     "type": "object",
                     "name": "parent_category"
                   }
                 ],
                 "label": "Subcategory",
                 "type": "object",
                 "name": "subcategory"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Age restriction",
                     "type": "string",
                     "name": "age_restriction"
                   },
                   {
                     "control_type": "text",
                     "label": "Presented by",
                     "type": "string",
                     "name": "presented_by"
                   },
                   {
                     "control_type": "text",
                     "label": "Door time",
                     "type": "string",
                     "name": "door_time"
                   }
                 ],
                 "label": "Music properties",
                 "type": "object",
                 "name": "music_properties"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Bookmarked",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Bookmarked",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "bookmarked"
                     },
                     "type": "boolean",
                     "name": "bookmarked"
                   }
                 ],
                 "label": "Bookmark info",
                 "type": "object",
                 "name": "bookmark_info"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Has available tickets",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Has available tickets",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "has_available_tickets"
                     },
                     "type": "boolean",
                     "name": "has_available_tickets"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Minimum ticket price",
                     "type": "object",
                     "name": "minimum_ticket_price"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Maximum ticket price",
                     "type": "object",
                     "name": "maximum_ticket_price"
                   },
                   {
                     "control_type": "text",
                     "label": "Is sold out",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is sold out",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_sold_out"
                     },
                     "type": "boolean",
                     "name": "is_sold_out"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Timezone",
                         "type": "string",
                         "name": "timezone"
                       },
                       {
                         "control_type": "text",
                         "label": "Utc",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "utc"
                       },
                       {
                         "control_type": "text",
                         "label": "Local",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "local"
                       }
                     ],
                     "label": "Start sales date",
                     "type": "object",
                     "name": "start_sales_date"
                   },
                   {
                     "control_type": "text",
                     "label": "Waitlist available",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Waitlist available",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "waitlist_available"
                     },
                     "type": "boolean",
                     "name": "waitlist_available"
                   }
                 ],
                 "label": "Ticket availability",
                 "type": "object",
                 "name": "ticket_availability"
               },
               {
                 "control_type": "text",
                 "label": "Listed",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Listed",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "listed"
                 },
                 "type": "boolean",
                 "name": "listed"
               },
               {
                 "control_type": "text",
                 "label": "Shareable",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Shareable",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "shareable"
                 },
                 "type": "boolean",
                 "name": "shareable"
               },
               {
                 "control_type": "text",
                 "label": "Invite only",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Invite only",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "invite_only"
                 },
                 "type": "boolean",
                 "name": "invite_only"
               },
               {
                 "control_type": "text",
                 "label": "Show remaining",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Show remaining",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "show_remaining"
                 },
                 "type": "boolean",
                 "name": "show_remaining"
               },
               {
                 "control_type": "text",
                 "label": "Password",
                 "type": "string",
                 "name": "password"
               },
               {
                 "control_type": "number",
                 "label": "Capacity",
                 "parse_output": "float_conversion",
                 "type": "number",
                 "name": "capacity"
               },
               {
                 "control_type": "text",
                 "label": "Capacity is custom",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Capacity is custom",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "capacity_is_custom"
                 },
                 "type": "boolean",
                 "name": "capacity_is_custom"
               },
               {
                 "control_type": "text",
                 "label": "Tx time limit",
                 "type": "string",
                 "name": "tx_time_limit"
               },
               {
                 "control_type": "text",
                 "label": "Hide start date",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Hide start date",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "hide_start_date"
                 },
                 "type": "boolean",
                 "name": "hide_start_date"
               },
               {
                 "control_type": "text",
                 "label": "Hide end date",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Hide end date",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "hide_end_date"
                 },
                 "type": "boolean",
                 "name": "hide_end_date"
               },
               {
                 "control_type": "text",
                 "label": "Locale",
                 "type": "string",
                 "name": "locale"
               },
               {
                 "control_type": "text",
                 "label": "Is locked",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is locked",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_locked"
                 },
                 "type": "boolean",
                 "name": "is_locked"
               },
               {
                 "control_type": "text",
                 "label": "Privacy setting",
                 "type": "string",
                 "name": "privacy_setting"
               },
               {
                 "control_type": "text",
                 "label": "Is externally ticketed",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is externally ticketed",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_externally_ticketed"
                 },
                 "type": "boolean",
                 "name": "is_externally_ticketed"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "External URL",
                     "type": "string",
                     "name": "external_url"
                   },
                   {
                     "control_type": "text",
                     "label": "Ticketing provider name",
                     "type": "string",
                     "name": "ticketing_provider_name"
                   },
                   {
                     "control_type": "text",
                     "label": "Is free",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is free",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_free"
                     },
                     "type": "boolean",
                     "name": "is_free"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Minimum ticket price",
                     "type": "object",
                     "name": "minimum_ticket_price"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Maximum ticket price",
                     "type": "object",
                     "name": "maximum_ticket_price"
                   },
                   {
                     "control_type": "text",
                     "label": "Sales start",
                     "type": "string",
                     "name": "sales_start"
                   },
                   {
                     "control_type": "text",
                     "label": "Sales end",
                     "type": "string",
                     "name": "sales_end"
                   }
                 ],
                 "label": "External ticketing",
                 "type": "object",
                 "name": "external_ticketing"
               },
               {
                 "control_type": "text",
                 "label": "Is series",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is series",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_series"
                 },
                 "type": "boolean",
                 "name": "is_series"
               },
               {
                 "control_type": "text",
                 "label": "Is series parent",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is series parent",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_series_parent"
                 },
                 "type": "boolean",
                 "name": "is_series_parent"
               },
               {
                 "control_type": "text",
                 "label": "Series ID",
                 "type": "string",
                 "name": "series_id"
               },
               {
                 "control_type": "text",
                 "label": "Is reserved seating",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is reserved seating",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_reserved_seating"
                 },
                 "type": "boolean",
                 "name": "is_reserved_seating"
               },
               {
                 "control_type": "text",
                 "label": "Show pick a seat",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Show pick a seat",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "show_pick_a_seat"
                 },
                 "type": "boolean",
                 "name": "show_pick_a_seat"
               },
               {
                 "control_type": "text",
                 "label": "Show seatmap thumbnail",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Show seatmap thumbnail",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "show_seatmap_thumbnail"
                 },
                 "type": "boolean",
                 "name": "show_seatmap_thumbnail"
               },
               {
                 "control_type": "text",
                 "label": "Show colors in seatmap thumbnail",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Show colors in seatmap thumbnail",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "show_colors_in_seatmap_thumbnail"
                 },
                 "type": "boolean",
                 "name": "show_colors_in_seatmap_thumbnail"
               },
               {
                 "control_type": "text",
                 "label": "Is free",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Is free",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "is_free"
                 },
                 "type": "boolean",
                 "name": "is_free"
               },
               {
                 "control_type": "text",
                 "label": "Source",
                 "type": "string",
                 "name": "source"
               },
               {
                 "control_type": "text",
                 "label": "Version",
                 "type": "string",
                 "name": "version"
               },
               {
                 "control_type": "text",
                 "label": "Resource URI",
                 "type": "string",
                 "name": "resource_uri"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Sales status",
                     "type": "string",
                     "name": "sales_status"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Timezone",
                         "type": "string",
                         "name": "timezone"
                       },
                       {
                         "control_type": "text",
                         "label": "Utc",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "utc"
                       },
                       {
                         "control_type": "text",
                         "label": "Local",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "local"
                       }
                     ],
                     "label": "Start sales date",
                     "type": "object",
                     "name": "start_sales_date"
                   }
                 ],
                 "label": "Event sales status",
                 "type": "object",
                 "name": "event_sales_status"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Created",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "created"
                   },
                   {
                     "control_type": "text",
                     "label": "Changed",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "changed"
                   },
                   {
                     "control_type": "text",
                     "label": "Country code",
                     "type": "string",
                     "name": "country_code"
                   },
                   {
                     "control_type": "text",
                     "label": "Currency code",
                     "type": "string",
                     "name": "currency_code"
                   },
                   {
                     "control_type": "text",
                     "label": "Checkout method",
                     "type": "string",
                     "name": "checkout_method"
                   },
                   {
                     "name": "offline_settings",
                     "type": "array",
                     "of": "object",
                     "label": "Offline settings",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Payment method",
                         "type": "string",
                         "name": "payment_method"
                       },
                       {
                         "control_type": "text",
                         "label": "Instructions",
                         "type": "string",
                         "name": "instructions"
                       }
                     ]
                   },
                   {
                     "control_type": "text",
                     "label": "User instrument vault ID",
                     "type": "string",
                     "name": "user_instrument_vault_id"
                   }
                 ],
                 "label": "Checkout settings",
                 "type": "object",
                 "name": "checkout_settings"
               }
             ],
             "label": "Event",
             "type": "object",
             "name": "event"
           },
           {
             "control_type": "text",
             "label": "Order ID",
             "type": "string",
             "name": "order_id"
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "ID",
                 "type": "string",
                 "name": "id"
               },
               {
                 "control_type": "text",
                 "label": "Created",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "created"
               },
               {
                 "control_type": "text",
                 "label": "Changed",
                 "render_input": "date_time_conversion",
                 "parse_output": "date_time_conversion",
                 "type": "date_time",
                 "name": "changed"
               },
               {
                 "control_type": "text",
                 "label": "Name",
                 "type": "string",
                 "name": "name"
               },
               {
                 "control_type": "text",
                 "label": "First name",
                 "type": "string",
                 "name": "first_name"
               },
               {
                 "control_type": "text",
                 "label": "Last name",
                 "type": "string",
                 "name": "last_name"
               },
               {
                 "control_type": "text",
                 "label": "Email",
                 "type": "string",
                 "name": "email"
               },
               {
                 "properties": [
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Base price",
                     "type": "object",
                     "name": "base_price"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Display price",
                     "type": "object",
                     "name": "display_price"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Display fee",
                     "type": "object",
                     "name": "display_fee"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Gross",
                     "type": "object",
                     "name": "gross"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Eventbrite fee",
                     "type": "object",
                     "name": "eventbrite_fee"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Payment fee",
                     "type": "object",
                     "name": "payment_fee"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Tax",
                     "type": "object",
                     "name": "tax"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Display tax",
                     "type": "object",
                     "name": "display_tax"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Price before discount",
                     "type": "object",
                     "name": "price_before_discount"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Currency",
                         "type": "string",
                         "name": "currency"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "control_type": "text",
                         "label": "Major value",
                         "type": "string",
                         "name": "major_value"
                       },
                       {
                         "control_type": "text",
                         "label": "Display",
                         "type": "string",
                         "name": "display"
                       }
                     ],
                     "label": "Discount amount",
                     "type": "object",
                     "name": "discount_amount"
                   },
                   {
                     "control_type": "text",
                     "label": "Discount type",
                     "type": "string",
                     "name": "discount_type"
                   },
                   {
                     "name": "fee_components",
                     "type": "array",
                     "of": "object",
                     "label": "Fee components",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Intermediate",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Intermediate",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "intermediate"
                         },
                         "type": "boolean",
                         "name": "intermediate"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Internal name",
                         "type": "string",
                         "name": "internal_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Group name",
                         "type": "string",
                         "name": "group_name"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "properties": [
                           {
                             "properties": [
                               {
                                 "control_type": "text",
                                 "label": "Currency",
                                 "type": "string",
                                 "name": "currency"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Value",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Major value",
                                 "type": "string",
                                 "name": "major_value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Display",
                                 "type": "string",
                                 "name": "display"
                               }
                             ],
                             "label": "Amount",
                             "type": "object",
                             "name": "amount"
                           },
                           {
                             "control_type": "text",
                             "label": "Reason",
                             "type": "string",
                             "name": "reason"
                           }
                         ],
                         "label": "Discount",
                         "type": "object",
                         "name": "discount"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           }
                         ],
                         "label": "Rule",
                         "type": "object",
                         "name": "rule"
                       },
                       {
                         "control_type": "text",
                         "label": "Base",
                         "type": "string",
                         "name": "base"
                       },
                       {
                         "control_type": "text",
                         "label": "Bucket",
                         "type": "string",
                         "name": "bucket"
                       },
                       {
                         "control_type": "text",
                         "label": "Recipient",
                         "type": "string",
                         "name": "recipient"
                       },
                       {
                         "control_type": "text",
                         "label": "Payer",
                         "type": "string",
                         "name": "payer"
                       }
                     ]
                   },
                   {
                     "name": "tax_components",
                     "type": "array",
                     "of": "object",
                     "label": "Tax components",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Intermediate",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Intermediate",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "intermediate"
                         },
                         "type": "boolean",
                         "name": "intermediate"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Internal name",
                         "type": "string",
                         "name": "internal_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Group name",
                         "type": "string",
                         "name": "group_name"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "properties": [
                           {
                             "properties": [
                               {
                                 "control_type": "text",
                                 "label": "Currency",
                                 "type": "string",
                                 "name": "currency"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Value",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Major value",
                                 "type": "string",
                                 "name": "major_value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Display",
                                 "type": "string",
                                 "name": "display"
                               }
                             ],
                             "label": "Amount",
                             "type": "object",
                             "name": "amount"
                           },
                           {
                             "control_type": "text",
                             "label": "Reason",
                             "type": "string",
                             "name": "reason"
                           }
                         ],
                         "label": "Discount",
                         "type": "object",
                         "name": "discount"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           }
                         ],
                         "label": "Rule",
                         "type": "object",
                         "name": "rule"
                       },
                       {
                         "control_type": "text",
                         "label": "Base",
                         "type": "string",
                         "name": "base"
                       },
                       {
                         "control_type": "text",
                         "label": "Bucket",
                         "type": "string",
                         "name": "bucket"
                       },
                       {
                         "control_type": "text",
                         "label": "Recipient",
                         "type": "string",
                         "name": "recipient"
                       },
                       {
                         "control_type": "text",
                         "label": "Payer",
                         "type": "string",
                         "name": "payer"
                       }
                     ]
                   },
                   {
                     "name": "shipping_components",
                     "type": "array",
                     "of": "object",
                     "label": "Shipping components",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Intermediate",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Intermediate",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "intermediate"
                         },
                         "type": "boolean",
                         "name": "intermediate"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Internal name",
                         "type": "string",
                         "name": "internal_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Group name",
                         "type": "string",
                         "name": "group_name"
                       },
                       {
                         "control_type": "number",
                         "label": "Value",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "value"
                       },
                       {
                         "properties": [
                           {
                             "properties": [
                               {
                                 "control_type": "text",
                                 "label": "Currency",
                                 "type": "string",
                                 "name": "currency"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Value",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Major value",
                                 "type": "string",
                                 "name": "major_value"
                               },
                               {
                                 "control_type": "text",
                                 "label": "Display",
                                 "type": "string",
                                 "name": "display"
                               }
                             ],
                             "label": "Amount",
                             "type": "object",
                             "name": "amount"
                           },
                           {
                             "control_type": "text",
                             "label": "Reason",
                             "type": "string",
                             "name": "reason"
                           }
                         ],
                         "label": "Discount",
                         "type": "object",
                         "name": "discount"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           }
                         ],
                         "label": "Rule",
                         "type": "object",
                         "name": "rule"
                       },
                       {
                         "control_type": "text",
                         "label": "Base",
                         "type": "string",
                         "name": "base"
                       },
                       {
                         "control_type": "text",
                         "label": "Bucket",
                         "type": "string",
                         "name": "bucket"
                       },
                       {
                         "control_type": "text",
                         "label": "Recipient",
                         "type": "string",
                         "name": "recipient"
                       },
                       {
                         "control_type": "text",
                         "label": "Payer",
                         "type": "string",
                         "name": "payer"
                       }
                     ]
                   },
                   {
                     "control_type": "text",
                     "label": "Has gts tax",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Has gts tax",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "has_gts_tax"
                     },
                     "type": "boolean",
                     "name": "has_gts_tax"
                   },
                   {
                     "control_type": "text",
                     "label": "Tax name",
                     "type": "string",
                     "name": "tax_name"
                   }
                 ],
                 "label": "Costs",
                 "type": "object",
                 "name": "costs"
               },
               {
                 "control_type": "text",
                 "label": "Event ID",
                 "type": "string",
                 "name": "event_id"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "ID",
                     "type": "string",
                     "name": "id"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Name",
                     "type": "object",
                     "name": "name"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Description",
                     "type": "object",
                     "name": "description"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Timezone",
                         "type": "string",
                         "name": "timezone"
                       },
                       {
                         "control_type": "text",
                         "label": "Utc",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "utc"
                       },
                       {
                         "control_type": "text",
                         "label": "Local",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "local"
                       }
                     ],
                     "label": "Start",
                     "type": "object",
                     "name": "start"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Timezone",
                         "type": "string",
                         "name": "timezone"
                       },
                       {
                         "control_type": "text",
                         "label": "Utc",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "utc"
                       },
                       {
                         "control_type": "text",
                         "label": "Local",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "local"
                       }
                     ],
                     "label": "End",
                     "type": "object",
                     "name": "end"
                   },
                   {
                     "control_type": "text",
                     "label": "URL",
                     "type": "string",
                     "name": "url"
                   },
                   {
                     "control_type": "text",
                     "label": "Vanity URL",
                     "type": "string",
                     "name": "vanity_url"
                   },
                   {
                     "control_type": "text",
                     "label": "Created",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "created"
                   },
                   {
                     "control_type": "text",
                     "label": "Changed",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "changed"
                   },
                   {
                     "control_type": "text",
                     "label": "Published",
                     "render_input": "date_time_conversion",
                     "parse_output": "date_time_conversion",
                     "type": "date_time",
                     "name": "published"
                   },
                   {
                     "control_type": "text",
                     "label": "Status",
                     "type": "string",
                     "name": "status"
                   },
                   {
                     "control_type": "text",
                     "label": "Currency",
                     "type": "string",
                     "name": "currency"
                   },
                   {
                     "control_type": "text",
                     "label": "Online event",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Online event",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "online_event"
                     },
                     "type": "boolean",
                     "name": "online_event"
                   },
                   {
                     "control_type": "text",
                     "label": "Organization ID",
                     "type": "string",
                     "name": "organization_id"
                   },
                   {
                     "control_type": "text",
                     "label": "Organizer ID",
                     "type": "string",
                     "name": "organizer_id"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Text",
                             "type": "string",
                             "name": "text"
                           },
                           {
                             "control_type": "text",
                             "label": "Html",
                             "type": "string",
                             "name": "html"
                           }
                         ],
                         "label": "Description",
                         "type": "object",
                         "name": "description"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Text",
                             "type": "string",
                             "name": "text"
                           },
                           {
                             "control_type": "text",
                             "label": "Html",
                             "type": "string",
                             "name": "html"
                           }
                         ],
                         "label": "Long description",
                         "type": "object",
                         "name": "long_description"
                       },
                       {
                         "control_type": "text",
                         "label": "Logo ID",
                         "type": "string",
                         "name": "logo_id"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           },
                           {
                             "control_type": "text",
                             "label": "URL",
                             "type": "string",
                             "name": "url"
                           },
                           {
                             "properties": [
                               {
                                 "properties": [
                                   {
                                     "control_type": "number",
                                     "label": "Y",
                                     "parse_output": "float_conversion",
                                     "type": "number",
                                     "name": "y"
                                   },
                                   {
                                     "control_type": "number",
                                     "label": "X",
                                     "parse_output": "float_conversion",
                                     "type": "number",
                                     "name": "x"
                                   }
                                 ],
                                 "label": "Top left",
                                 "type": "object",
                                 "name": "top_left"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Width",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "width"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Height",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "height"
                               }
                             ],
                             "label": "Crop mask",
                             "type": "object",
                             "name": "crop_mask"
                           },
                           {
                             "properties": [
                               {
                                 "control_type": "text",
                                 "label": "URL",
                                 "type": "string",
                                 "name": "url"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Width",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "width"
                               },
                               {
                                 "control_type": "number",
                                 "label": "Height",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "height"
                               }
                             ],
                             "label": "Original",
                             "type": "object",
                             "name": "original"
                           },
                           {
                             "control_type": "text",
                             "label": "Aspect ratio",
                             "type": "string",
                             "name": "aspect_ratio"
                           },
                           {
                             "control_type": "text",
                             "label": "Edge color",
                             "type": "string",
                             "name": "edge_color"
                           },
                           {
                             "control_type": "text",
                             "label": "Edge color set",
                             "render_input": {},
                             "parse_output": {},
                             "toggle_hint": "Select from option list",
                             "toggle_field": {
                               "label": "Edge color set",
                               "control_type": "text",
                               "toggle_hint": "Use custom value",
                               "type": "boolean",
                               "name": "edge_color_set"
                             },
                             "type": "boolean",
                             "name": "edge_color_set"
                           }
                         ],
                         "label": "Logo",
                         "type": "object",
                         "name": "logo"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "URL",
                         "type": "string",
                         "name": "url"
                       },
                       {
                         "control_type": "number",
                         "label": "Num past events",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "num_past_events"
                       },
                       {
                         "control_type": "number",
                         "label": "Num future events",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "num_future_events"
                       },
                       {
                         "control_type": "text",
                         "label": "Twitter",
                         "type": "string",
                         "name": "twitter"
                       },
                       {
                         "control_type": "text",
                         "label": "Facebook",
                         "type": "string",
                         "name": "facebook"
                       }
                     ],
                     "label": "Organizer",
                     "type": "object",
                     "name": "organizer"
                   },
                   {
                     "control_type": "text",
                     "label": "Logo ID",
                     "type": "string",
                     "name": "logo_id"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "URL",
                         "type": "string",
                         "name": "url"
                       },
                       {
                         "properties": [
                           {
                             "properties": [
                               {
                                 "control_type": "number",
                                 "label": "Y",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "y"
                               },
                               {
                                 "control_type": "number",
                                 "label": "X",
                                 "parse_output": "float_conversion",
                                 "type": "number",
                                 "name": "x"
                               }
                             ],
                             "label": "Top left",
                             "type": "object",
                             "name": "top_left"
                           },
                           {
                             "control_type": "number",
                             "label": "Width",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "width"
                           },
                           {
                             "control_type": "number",
                             "label": "Height",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "height"
                           }
                         ],
                         "label": "Crop mask",
                         "type": "object",
                         "name": "crop_mask"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "URL",
                             "type": "string",
                             "name": "url"
                           },
                           {
                             "control_type": "number",
                             "label": "Width",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "width"
                           },
                           {
                             "control_type": "number",
                             "label": "Height",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "height"
                           }
                         ],
                         "label": "Original",
                         "type": "object",
                         "name": "original"
                       },
                       {
                         "control_type": "text",
                         "label": "Aspect ratio",
                         "type": "string",
                         "name": "aspect_ratio"
                       },
                       {
                         "control_type": "text",
                         "label": "Edge color",
                         "type": "string",
                         "name": "edge_color"
                       },
                       {
                         "control_type": "text",
                         "label": "Edge color set",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Edge color set",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "edge_color_set"
                         },
                         "type": "boolean",
                         "name": "edge_color_set"
                       }
                     ],
                     "label": "Logo",
                     "type": "object",
                     "name": "logo"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Age restriction",
                         "type": "string",
                         "name": "age_restriction"
                       },
                       {
                         "control_type": "number",
                         "label": "Capacity",
                         "parse_output": "float_conversion",
                         "type": "number",
                         "name": "capacity"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Address 1",
                             "type": "string",
                             "name": "address_1"
                           },
                           {
                             "control_type": "text",
                             "label": "Address 2",
                             "type": "string",
                             "name": "address_2"
                           },
                           {
                             "control_type": "text",
                             "label": "City",
                             "type": "string",
                             "name": "city"
                           },
                           {
                             "control_type": "text",
                             "label": "Region",
                             "type": "string",
                             "name": "region"
                           },
                           {
                             "control_type": "text",
                             "label": "Postal code",
                             "type": "string",
                             "name": "postal_code"
                           },
                           {
                             "control_type": "text",
                             "label": "Country",
                             "type": "string",
                             "name": "country"
                           },
                           {
                             "control_type": "text",
                             "label": "Latitude",
                             "type": "string",
                             "name": "latitude"
                           },
                           {
                             "control_type": "text",
                             "label": "Longitude",
                             "type": "string",
                             "name": "longitude"
                           }
                         ],
                         "label": "Address",
                         "type": "object",
                         "name": "address"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Latitude",
                         "type": "string",
                         "name": "latitude"
                       },
                       {
                         "control_type": "text",
                         "label": "Longitude",
                         "type": "string",
                         "name": "longitude"
                       }
                     ],
                     "label": "Venue",
                     "type": "object",
                     "name": "venue"
                   },
                   {
                     "control_type": "text",
                     "label": "Format ID",
                     "type": "string",
                     "name": "format_id"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Name localized",
                         "type": "string",
                         "name": "name_localized"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name",
                         "type": "string",
                         "name": "short_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name localized",
                         "type": "string",
                         "name": "short_name_localized"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       }
                     ],
                     "label": "Format",
                     "type": "object",
                     "name": "format"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "control_type": "text",
                         "label": "Name localized",
                         "type": "string",
                         "name": "name_localized"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name",
                         "type": "string",
                         "name": "short_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Short name localized",
                         "type": "string",
                         "name": "short_name_localized"
                       },
                       {
                         "name": "subcategories",
                         "type": "array",
                         "of": "object",
                         "label": "Subcategories",
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           },
                           {
                             "control_type": "text",
                             "label": "Resource URI",
                             "type": "string",
                             "name": "resource_uri"
                           },
                           {
                             "control_type": "text",
                             "label": "Name",
                             "type": "string",
                             "name": "name"
                           },
                           {
                             "properties": [],
                             "label": "Parent category",
                             "type": "object",
                             "name": "parent_category"
                           }
                         ]
                       }
                     ],
                     "label": "Category",
                     "type": "object",
                     "name": "category"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "ID",
                         "type": "string",
                         "name": "id"
                       },
                       {
                         "control_type": "text",
                         "label": "Resource URI",
                         "type": "string",
                         "name": "resource_uri"
                       },
                       {
                         "control_type": "text",
                         "label": "Name",
                         "type": "string",
                         "name": "name"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "ID",
                             "type": "string",
                             "name": "id"
                           },
                           {
                             "control_type": "text",
                             "label": "Resource URI",
                             "type": "string",
                             "name": "resource_uri"
                           },
                           {
                             "control_type": "text",
                             "label": "Name",
                             "type": "string",
                             "name": "name"
                           },
                           {
                             "control_type": "text",
                             "label": "Name localized",
                             "type": "string",
                             "name": "name_localized"
                           },
                           {
                             "control_type": "text",
                             "label": "Short name",
                             "type": "string",
                             "name": "short_name"
                           },
                           {
                             "control_type": "text",
                             "label": "Short name localized",
                             "type": "string",
                             "name": "short_name_localized"
                           }
                         ],
                         "label": "Parent category",
                         "type": "object",
                         "name": "parent_category"
                       }
                     ],
                     "label": "Subcategory",
                     "type": "object",
                     "name": "subcategory"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Age restriction",
                         "type": "string",
                         "name": "age_restriction"
                       },
                       {
                         "control_type": "text",
                         "label": "Presented by",
                         "type": "string",
                         "name": "presented_by"
                       },
                       {
                         "control_type": "text",
                         "label": "Door time",
                         "type": "string",
                         "name": "door_time"
                       }
                     ],
                     "label": "Music properties",
                     "type": "object",
                     "name": "music_properties"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Bookmarked",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Bookmarked",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "bookmarked"
                         },
                         "type": "boolean",
                         "name": "bookmarked"
                       }
                     ],
                     "label": "Bookmark info",
                     "type": "object",
                     "name": "bookmark_info"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Has available tickets",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Has available tickets",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "has_available_tickets"
                         },
                         "type": "boolean",
                         "name": "has_available_tickets"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Currency",
                             "type": "string",
                             "name": "currency"
                           },
                           {
                             "control_type": "number",
                             "label": "Value",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "value"
                           },
                           {
                             "control_type": "text",
                             "label": "Major value",
                             "type": "string",
                             "name": "major_value"
                           },
                           {
                             "control_type": "text",
                             "label": "Display",
                             "type": "string",
                             "name": "display"
                           }
                         ],
                         "label": "Minimum ticket price",
                         "type": "object",
                         "name": "minimum_ticket_price"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Currency",
                             "type": "string",
                             "name": "currency"
                           },
                           {
                             "control_type": "number",
                             "label": "Value",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "value"
                           },
                           {
                             "control_type": "text",
                             "label": "Major value",
                             "type": "string",
                             "name": "major_value"
                           },
                           {
                             "control_type": "text",
                             "label": "Display",
                             "type": "string",
                             "name": "display"
                           }
                         ],
                         "label": "Maximum ticket price",
                         "type": "object",
                         "name": "maximum_ticket_price"
                       },
                       {
                         "control_type": "text",
                         "label": "Is sold out",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Is sold out",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "is_sold_out"
                         },
                         "type": "boolean",
                         "name": "is_sold_out"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Timezone",
                             "type": "string",
                             "name": "timezone"
                           },
                           {
                             "control_type": "text",
                             "label": "Utc",
                             "render_input": "date_time_conversion",
                             "parse_output": "date_time_conversion",
                             "type": "date_time",
                             "name": "utc"
                           },
                           {
                             "control_type": "text",
                             "label": "Local",
                             "render_input": "date_time_conversion",
                             "parse_output": "date_time_conversion",
                             "type": "date_time",
                             "name": "local"
                           }
                         ],
                         "label": "Start sales date",
                         "type": "object",
                         "name": "start_sales_date"
                       },
                       {
                         "control_type": "text",
                         "label": "Waitlist available",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Waitlist available",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "waitlist_available"
                         },
                         "type": "boolean",
                         "name": "waitlist_available"
                       }
                     ],
                     "label": "Ticket availability",
                     "type": "object",
                     "name": "ticket_availability"
                   },
                   {
                     "control_type": "text",
                     "label": "Listed",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Listed",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "listed"
                     },
                     "type": "boolean",
                     "name": "listed"
                   },
                   {
                     "control_type": "text",
                     "label": "Shareable",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Shareable",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "shareable"
                     },
                     "type": "boolean",
                     "name": "shareable"
                   },
                   {
                     "control_type": "text",
                     "label": "Invite only",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Invite only",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "invite_only"
                     },
                     "type": "boolean",
                     "name": "invite_only"
                   },
                   {
                     "control_type": "text",
                     "label": "Show remaining",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Show remaining",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "show_remaining"
                     },
                     "type": "boolean",
                     "name": "show_remaining"
                   },
                   {
                     "control_type": "text",
                     "label": "Password",
                     "type": "string",
                     "name": "password"
                   },
                   {
                     "control_type": "number",
                     "label": "Capacity",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "capacity"
                   },
                   {
                     "control_type": "text",
                     "label": "Capacity is custom",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Capacity is custom",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "capacity_is_custom"
                     },
                     "type": "boolean",
                     "name": "capacity_is_custom"
                   },
                   {
                     "control_type": "text",
                     "label": "Tx time limit",
                     "type": "string",
                     "name": "tx_time_limit"
                   },
                   {
                     "control_type": "text",
                     "label": "Hide start date",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Hide start date",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "hide_start_date"
                     },
                     "type": "boolean",
                     "name": "hide_start_date"
                   },
                   {
                     "control_type": "text",
                     "label": "Hide end date",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Hide end date",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "hide_end_date"
                     },
                     "type": "boolean",
                     "name": "hide_end_date"
                   },
                   {
                     "control_type": "text",
                     "label": "Locale",
                     "type": "string",
                     "name": "locale"
                   },
                   {
                     "control_type": "text",
                     "label": "Is locked",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is locked",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_locked"
                     },
                     "type": "boolean",
                     "name": "is_locked"
                   },
                   {
                     "control_type": "text",
                     "label": "Privacy setting",
                     "type": "string",
                     "name": "privacy_setting"
                   },
                   {
                     "control_type": "text",
                     "label": "Is externally ticketed",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is externally ticketed",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_externally_ticketed"
                     },
                     "type": "boolean",
                     "name": "is_externally_ticketed"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "External URL",
                         "type": "string",
                         "name": "external_url"
                       },
                       {
                         "control_type": "text",
                         "label": "Ticketing provider name",
                         "type": "string",
                         "name": "ticketing_provider_name"
                       },
                       {
                         "control_type": "text",
                         "label": "Is free",
                         "render_input": {},
                         "parse_output": {},
                         "toggle_hint": "Select from option list",
                         "toggle_field": {
                           "label": "Is free",
                           "control_type": "text",
                           "toggle_hint": "Use custom value",
                           "type": "boolean",
                           "name": "is_free"
                         },
                         "type": "boolean",
                         "name": "is_free"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Currency",
                             "type": "string",
                             "name": "currency"
                           },
                           {
                             "control_type": "number",
                             "label": "Value",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "value"
                           },
                           {
                             "control_type": "text",
                             "label": "Major value",
                             "type": "string",
                             "name": "major_value"
                           },
                           {
                             "control_type": "text",
                             "label": "Display",
                             "type": "string",
                             "name": "display"
                           }
                         ],
                         "label": "Minimum ticket price",
                         "type": "object",
                         "name": "minimum_ticket_price"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Currency",
                             "type": "string",
                             "name": "currency"
                           },
                           {
                             "control_type": "number",
                             "label": "Value",
                             "parse_output": "float_conversion",
                             "type": "number",
                             "name": "value"
                           },
                           {
                             "control_type": "text",
                             "label": "Major value",
                             "type": "string",
                             "name": "major_value"
                           },
                           {
                             "control_type": "text",
                             "label": "Display",
                             "type": "string",
                             "name": "display"
                           }
                         ],
                         "label": "Maximum ticket price",
                         "type": "object",
                         "name": "maximum_ticket_price"
                       },
                       {
                         "control_type": "text",
                         "label": "Sales start",
                         "type": "string",
                         "name": "sales_start"
                       },
                       {
                         "control_type": "text",
                         "label": "Sales end",
                         "type": "string",
                         "name": "sales_end"
                       }
                     ],
                     "label": "External ticketing",
                     "type": "object",
                     "name": "external_ticketing"
                   },
                   {
                     "control_type": "text",
                     "label": "Is series",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is series",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_series"
                     },
                     "type": "boolean",
                     "name": "is_series"
                   },
                   {
                     "control_type": "text",
                     "label": "Is series parent",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is series parent",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_series_parent"
                     },
                     "type": "boolean",
                     "name": "is_series_parent"
                   },
                   {
                     "control_type": "text",
                     "label": "Series ID",
                     "type": "string",
                     "name": "series_id"
                   },
                   {
                     "control_type": "text",
                     "label": "Is reserved seating",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is reserved seating",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_reserved_seating"
                     },
                     "type": "boolean",
                     "name": "is_reserved_seating"
                   },
                   {
                     "control_type": "text",
                     "label": "Show pick a seat",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Show pick a seat",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "show_pick_a_seat"
                     },
                     "type": "boolean",
                     "name": "show_pick_a_seat"
                   },
                   {
                     "control_type": "text",
                     "label": "Show seatmap thumbnail",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Show seatmap thumbnail",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "show_seatmap_thumbnail"
                     },
                     "type": "boolean",
                     "name": "show_seatmap_thumbnail"
                   },
                   {
                     "control_type": "text",
                     "label": "Show colors in seatmap thumbnail",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Show colors in seatmap thumbnail",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "show_colors_in_seatmap_thumbnail"
                     },
                     "type": "boolean",
                     "name": "show_colors_in_seatmap_thumbnail"
                   },
                   {
                     "control_type": "text",
                     "label": "Is free",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Is free",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "is_free"
                     },
                     "type": "boolean",
                     "name": "is_free"
                   },
                   {
                     "control_type": "text",
                     "label": "Source",
                     "type": "string",
                     "name": "source"
                   },
                   {
                     "control_type": "text",
                     "label": "Version",
                     "type": "string",
                     "name": "version"
                   },
                   {
                     "control_type": "text",
                     "label": "Resource URI",
                     "type": "string",
                     "name": "resource_uri"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Sales status",
                         "type": "string",
                         "name": "sales_status"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Timezone",
                             "type": "string",
                             "name": "timezone"
                           },
                           {
                             "control_type": "text",
                             "label": "Utc",
                             "render_input": "date_time_conversion",
                             "parse_output": "date_time_conversion",
                             "type": "date_time",
                             "name": "utc"
                           },
                           {
                             "control_type": "text",
                             "label": "Local",
                             "render_input": "date_time_conversion",
                             "parse_output": "date_time_conversion",
                             "type": "date_time",
                             "name": "local"
                           }
                         ],
                         "label": "Start sales date",
                         "type": "object",
                         "name": "start_sales_date"
                       }
                     ],
                     "label": "Event sales status",
                     "type": "object",
                     "name": "event_sales_status"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Created",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "created"
                       },
                       {
                         "control_type": "text",
                         "label": "Changed",
                         "render_input": "date_time_conversion",
                         "parse_output": "date_time_conversion",
                         "type": "date_time",
                         "name": "changed"
                       },
                       {
                         "control_type": "text",
                         "label": "Country code",
                         "type": "string",
                         "name": "country_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Currency code",
                         "type": "string",
                         "name": "currency_code"
                       },
                       {
                         "control_type": "text",
                         "label": "Checkout method",
                         "type": "string",
                         "name": "checkout_method"
                       },
                       {
                         "name": "offline_settings",
                         "type": "array",
                         "of": "object",
                         "label": "Offline settings",
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Payment method",
                             "type": "string",
                             "name": "payment_method"
                           },
                           {
                             "control_type": "text",
                             "label": "Instructions",
                             "type": "string",
                             "name": "instructions"
                           }
                         ]
                       },
                       {
                         "control_type": "text",
                         "label": "User instrument vault ID",
                         "type": "string",
                         "name": "user_instrument_vault_id"
                       }
                     ],
                     "label": "Checkout settings",
                     "type": "object",
                     "name": "checkout_settings"
                   }
                 ],
                 "label": "Event",
                 "type": "object",
                 "name": "event"
               },
               {
                 "control_type": "number",
                 "label": "Time remaining",
                 "parse_output": "float_conversion",
                 "type": "number",
                 "name": "time_remaining"
               },
               {
                 "control_type": "text",
                 "label": "Resource URI",
                 "type": "string",
                 "name": "resource_uri"
               },
               {
                 "control_type": "text",
                 "label": "Status",
                 "type": "string",
                 "name": "status"
               },
               {
                 "properties": [
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Confirmation message",
                     "type": "object",
                     "name": "confirmation_message"
                   },
                   {
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Text",
                         "type": "string",
                         "name": "text"
                       },
                       {
                         "control_type": "text",
                         "label": "Html",
                         "type": "string",
                         "name": "html"
                       }
                     ],
                     "label": "Instructions",
                     "type": "object",
                     "name": "instructions"
                   },
                   {
                     "control_type": "text",
                     "label": "Event ID",
                     "type": "string",
                     "name": "event_id"
                   },
                   {
                     "control_type": "text",
                     "label": "Refund request enabled",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Refund request enabled",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "refund_request_enabled"
                     },
                     "type": "boolean",
                     "name": "refund_request_enabled"
                   },
                   {
                     "name": "ticket_class_confirmation_settings",
                     "type": "array",
                     "of": "object",
                     "label": "Ticket class confirmation settings",
                     "properties": [
                       {
                         "control_type": "text",
                         "label": "Ticket class ID",
                         "type": "string",
                         "name": "ticket_class_id"
                       },
                       {
                         "control_type": "text",
                         "label": "Event ID",
                         "type": "string",
                         "name": "event_id"
                       },
                       {
                         "properties": [
                           {
                             "control_type": "text",
                             "label": "Text",
                             "type": "string",
                             "name": "text"
                           },
                           {
                             "control_type": "text",
                             "label": "Html",
                             "type": "string",
                             "name": "html"
                           }
                         ],
                         "label": "Confirmation message",
                         "type": "object",
                         "name": "confirmation_message"
                       }
                     ]
                   }
                 ],
                 "label": "Ticket buyer settings",
                 "type": "object",
                 "name": "ticket_buyer_settings"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "Has contact list",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Has contact list",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "has_contact_list"
                     },
                     "type": "boolean",
                     "name": "has_contact_list"
                   },
                   {
                     "control_type": "text",
                     "label": "Has opted in",
                     "render_input": {},
                     "parse_output": {},
                     "toggle_hint": "Select from option list",
                     "toggle_field": {
                       "label": "Has opted in",
                       "control_type": "text",
                       "toggle_hint": "Use custom value",
                       "type": "boolean",
                       "name": "has_opted_in"
                     },
                     "type": "boolean",
                     "name": "has_opted_in"
                   },
                   {
                     "control_type": "text",
                     "label": "Type",
                     "type": "string",
                     "name": "_type"
                   }
                 ],
                 "label": "Contact list preferences",
                 "type": "object",
                 "name": "contact_list_preferences"
               }
             ],
             "label": "Order",
             "type": "object",
             "name": "order"
           },
           {
             "control_type": "text",
             "label": "Guestlist ID",
             "type": "string",
             "name": "guestlist_id"
           },
           {
             "control_type": "text",
             "label": "Invited by",
             "type": "string",
             "name": "invited_by"
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "Unit ID",
                 "type": "string",
                 "name": "unit_id"
               },
               {
                 "control_type": "text",
                 "label": "Description",
                 "type": "string",
                 "name": "description"
               },
               {
                 "properties": [
                   {
                     "control_type": "text",
                     "label": "URL",
                     "type": "string",
                     "name": "url"
                   },
                   {
                     "control_type": "number",
                     "label": "X",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "x"
                   },
                   {
                     "control_type": "number",
                     "label": "Y",
                     "parse_output": "float_conversion",
                     "type": "number",
                     "name": "y"
                   }
                 ],
                 "label": "Location image",
                 "type": "object",
                 "name": "location_image"
               },
               {
                 "name": "labels",
                 "type": "array",
                 "of": "string",
                 "control_type": "text",
                 "label": "Labels"
               },
               {
                 "name": "titles",
                 "type": "array",
                 "of": "string",
                 "control_type": "text",
                 "label": "Titles"
               }
             ],
             "label": "Assigned unit",
             "type": "object",
             "name": "assigned_unit"
           },
           {
             "control_type": "text",
             "label": "Delivery method",
             "type": "string",
             "name": "delivery_method"
           },
           {
             "control_type": "text",
             "label": "Variant ID",
             "type": "string",
             "name": "variant_id"
           },
           {
             "properties": [
               {
                 "control_type": "text",
                 "label": "Has contact list",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Has contact list",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "has_contact_list"
                 },
                 "type": "boolean",
                 "name": "has_contact_list"
               },
               {
                 "control_type": "text",
                 "label": "Has opted in",
                 "render_input": {},
                 "parse_output": {},
                 "toggle_hint": "Select from option list",
                 "toggle_field": {
                   "label": "Has opted in",
                   "control_type": "text",
                   "toggle_hint": "Use custom value",
                   "type": "boolean",
                   "name": "has_opted_in"
                 },
                 "type": "boolean",
                 "name": "has_opted_in"
               },
               {
                 "control_type": "text",
                 "label": "Type",
                 "type": "string",
                 "name": "_type"
               }
             ],
             "label": "Contact list preferences",
             "type": "object",
             "name": "contact_list_preferences"
           },
           {
             "control_type": "text",
             "label": "Resource URI",
             "type": "string",
             "name": "resource_uri"
           }
        ]
      end
    }
  },
  pick_lists: {
    orgs: lambda do |connection|
      get("https://www.eventbriteapi.com/v3/users/me/organizations/")["organizations"].
        map { |org| [org["name"], org["id"]] }
    end
  }
}
