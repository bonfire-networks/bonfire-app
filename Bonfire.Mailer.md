# Email Delivery in Bonfire

Email delivery is a crucial component of many web applications, including your Bonfire instance. It's used for various purposes such as:

- Sending signup confirmation emails
- Delivering password reset links
- Notifying users of new messages or activities
- Sending alerts to administrators or moderators

To set up email delivery for your Bonfire instance, you'll need to choose an email delivery method and configure it properly. This guide will help you through that process.


## Before You Begin

1. **Choose Email Delivery Method and/or Provider**: You may choose to sign up with one of the email service providers listed in this guide. Each provider has its own pricing, features, and delivery rates.

2. **Domain Configuration**: To ensure reliable email delivery and avoid spam filters, you should configure your [email-related DNS settings](https://www.cloudflare.com/en-gb/learning/email-security/dmarc-dkim-spf/) for your instance's domain name. This typically involves setting up:
   - MX (Mail Exchanger) records
   - SPF (Sender Policy Framework) records
   - DKIM (DomainKeys Identified Mail) records
   - DMARC (Domain-based Message Authentication, Reporting, and Conformance) records

Your chosen email provider should provide instructions on how to set these up for your domain.

3. **Environment Variables**: Bonfire uses environment variables for configuration. You'll need to set these variables in your deployment environment or in a `.env` file if you're running Bonfire locally or using Co-op Cloud.

For all email delivery methods, you'll need to set the following environment variables:

- `MAIL_BACKEND` environment variable to choose your email delivery method or provider. 
- `MAIL_DOMAIN` or `HOSTNAME`: Your domain name
- `MAIL_FROM`: The email address from which emails will be sent (this should match the domain name you set up with SPF/DKIM/DMARC, which will usually be your instance's domain)


## Choosing an Email Delivery Method

## 1. Default Behaviour: Direct SMTP Delivery

If no specific email configuration is set, Bonfire will attempt to deliver emails directly to the recipients' SMTP servers. Here's what you need to know about this default behaviour:

- **What it means**: Your server will try to connect directly to the recipient's email server (e.g. a provider such as Gmail or an organisation's own mail server) to deliver the email.

- **Pros**: It requires no additional configuration and can work for basic setups.

- **Cons**: This method is often unreliable and prone to several issues:
  1. **Spam Filters**: Emails sent this way are more likely to be marked as spam or rejected entirely.
  2. **Deliverability**: Many recipient servers may flat-out reject IP addresses not properly set up for email sending.
  3. **DNS Configuration**: Without proper DNS records (SPF, DKIM, DMARK, etc.), your emails are more likely to be treated as suspicious.
  4. **IP Reputation**: If your server's IP address isn't established as a legitimate email sender, deliverability will suffer.

- **Important**: While this default method can work for testing or in very small-scale scenarios, it is strongly recommended to configure a proper email delivery service for any production use of Bonfire. If you want to try this method anyway, make sure to configure [SPF, DKIM, DMARK, etc.](https://www.cloudflare.com/en-gb/learning/email-security/dmarc-dkim-spf/) for your instance domain name and IP address.


### 2. Managed Email Service Providers

These providers offer comprehensive email delivery services, usually featuring analytics, bounce handling, high deliverability rates, etc.

> Note: the information about free tiers and pricing are only meant to serve as a rough indication of the options available and may be outdated or inaccurate (we'd welcome PRs with any updates of course). Please check with each provider's website for more details.


#### Brevo (formerly Sendinblue)
- Website: [brevo.com](https://www.brevo.com/)
- Free Tier: 300 emails per day, then $15+/month or pay-as-you-go ($59 per 10,000 emails)  
```
MAIL_BACKEND=brevo
MAIL_KEY=your_brevo_api_key
MAIL_FROM=email@instance.domain
```

#### Mailjet
- Website: [mailjet.com](https://www.mailjet.com/)
- Free Tier: 200 emails per day, then $17+/month
```
MAIL_BACKEND=mailjet
MAIL_KEY=your_mailjet_api_key
MAIL_PRIVATE_KEY=your_mailjet_secret_key
MAIL_FROM=email@instance.domain
```

#### SMTP2GO
- Website: [smtp2go.com](https://www.smtp2go.com/)
- Free Tier: 200 emails per day (up to 1,000 emails per month), then $10+/month
```
MAIL_BACKEND=SMTP2GO
MAIL_KEY=your_smtp2go_api_key
MAIL_FROM=email@instance.domain
```

#### Mailtrap 
- Website: [mailtrap.io](https://mailtrap.io/)
- Free Tier: 200 emails per day (up to 1,000 emails per month), then $15+/month
```
MAIL_BACKEND=mailtrap
MAIL_KEY=your_mailtrap_api_key
MAIL_FROM=email@instance.domain
```

#### Mailgun
- Website: [www.mailgun.com](https://www.mailgun.com/)
- Free Tier: 100 emails per day, then $15+/month
```
MAIL_BACKEND=mailgun
MAIL_KEY=your_mailgun_api_key
MAIL_BASE_URI=https://api.eu.mailgun.net/v3
MAIL_FROM=email@instance.domain
```
Note: The `MAIL_BASE_URI` depends on your Mailgun registration region. The default is set to EU, adjust if necessary.

#### Twilio SendGrid 
- Website: [sendgrid.com](https://sendgrid.com/)
- Free Tier: 100 emails per day, then $20+/month
```
MAIL_BACKEND=sendgrid
MAIL_KEY=your_sendgrid_api_key
MAIL_FROM=email@instance.domain
```

#### Postmark
- Website: [postmarkapp.com](https://postmarkapp.com/)
- Free Tier: 100 emails per month, then $15+/month
```
MAIL_BACKEND=postmark
MAIL_KEY=your_postmark_api_key
MAIL_FROM=email@instance.domain
```

#### Zoho ZeptoMail
- Website: [zoho.com](https://www.zoho.com/zeptomail/)
- First 10,000 emails are free, then €2,50 per 10,000 emails
```
MAIL_BACKEND=zepto
MAIL_KEY=your_zeptomail_api_key
MAIL_FROM=email@instance.domain
```

#### Scaleway
- Website: [scaleway.com](https://www.scaleway.com/en/transactional-email-tem/)
- No free tier, pay-as-you-go pricing (€2.50 per 10,000 emails)
```
MAIL_BACKEND=scaleway
MAIL_KEY=your_scaleway_api_key
MAIL_PROJECT_ID=your_scaleway_project_id
MAIL_PRIVATE_KEY=your_scaleway_secret_key
MAIL_FROM=email@instance.domain
```

#### Gmail
- Website: [gmail.com](https://developers.google.com/gmail/api)
- Free Tier: 500 emails per day
```
MAIL_BACKEND=gmail
MAIL_KEY=your_gmail_api_key 
MAIL_FROM=email@instance.domain
# ^ OAuth2 access token with `gmail.compose` scope
```
Note: Using Gmail for sending application email is generally not recommended for production use.

#### MailPace
- Website: [mailpace.com](https://mailpace.com/)
- No free tier, starts at £2.50 per month for up to 1,000 emails
```
MAIL_BACKEND=mailpace
MAIL_KEY=your_mailpace_api_key
MAIL_FROM=email@instance.domain
```

#### Mandrill (Mailchimp Transactional)
- Website: [mailchimp.com](https://mailchimp.com/features/transactional-email/)
- No free tier, pay-as-you-go pricing
```
MAIL_BACKEND=mandrill
MAIL_KEY=your_mandrill_api_key
MAIL_FROM=email@instance.domain
```

#### Bird / SparkPost
- Website: [bird.com](https://bird.com/api/email)
- No free tier, pay-as-you-go pricing
```
MAIL_BACKEND=sparkpost
MAIL_KEY=your_sparkpost_api_key
MAIL_BASE_URI=https://api.eu.sparkpost.com
MAIL_FROM=email@instance.domain
```
Note: The `MAIL_BASE_URI` depends on your SparkPost registration region. The default is set to EU, adjust if necessary.

#### Sendcloud (China)
- Website: [sendcloud.net](https://www.sendcloud.net/)
- Free Tier: 10 emails per day
```
MAIL_BACKEND=sendcloud
MAIL_KEY=your_sendcloud_api_key
MAIL_USER=your_sendcloud_api_user
MAIL_FROM=email@instance.domain
```

#### SocketLabs
- Website: [socketlabs.com](https://www.socketlabs.com/)
- No free tier
```
MAIL_BACKEND=socketlabs
MAIL_KEY=your_socketlabs_api_key
MAIL_SERVER=your_socketlabs_server_id
MAIL_PRIVATE_KEY=your_socketlabs_api_key
MAIL_FROM=email@instance.domain
```

#### Campaign Monitor
- Website: [campaignmonitor.com](https://www.campaignmonitor.com/)
- No free tier, pay-as-you-go pricing
```
MAIL_BACKEND=campaign_monitor
MAIL_KEY=your_campaign_monitor_api_key
MAIL_FROM=email@instance.domain
```

#### Amazon AWS SES
- Website: [aws.amazon.com](https://aws.amazon.com/ses/)
- Free Tier: 3,000 message / month (only for the first 12 months, and extra AWS charges may still apply)

Amazon SES can be configured in two ways:

1. Using existing AWS credentials (if already configured for S3 file storage, you can simplify configuration and use the same AWS credentials for both file storage and email delivery):
```
MAIL_BACKEND=aws
MAIL_FROM=email@instance.domain
```
Note: This method will automatically use the credentials set by `UPLOADS_S3_ACCESS_KEY_ID` and `UPLOADS_S3_SECRET_ACCESS_KEY`. No additional configuration is needed if these are already set up for a Bonfire extension (such as `Bonfire.Files`) which uses S3 file storage.

2. Using dedicated credentials, if you don't use AWS for S3 file storage or you want to use different AWS accounts for file storage and email delivery:
```
MAIL_BACKEND=aws
MAIL_KEY=your_aws_access_key_id
MAIL_PRIVATE_KEY=your_aws_secret_access_key
MAIL_REGION=your_aws_region
MAIL_FROM=email@instance.domain
```

Note: 
- If not specified, `MAIL_REGION` defaults to "eu-west-1".


### 3. Direct Email Sending Methods

These methods involve sending emails directly or through your own mail server. They require more setup and maintenance but offer more control.

#### Default: Direct SMTP Delivery
- When no specific email configuration is set, Bonfire will attempt to deliver emails directly to the recipients' SMTP servers.
- No additional configuration is needed as this is the default behaviour, but it's not recommended for production use due to deliverability issues ([see above](#module-default-behaviour-direct-smtp-delivery)).

#### SMTP
SMTP (Simple Mail Transfer Protocol) is the standard method for sending emails across the internet. It's like the postal service for digital messages, ensuring your emails reach their destination regardless of the systems involved. While many opt for using a dedicated email delivery provider (see above), if you already run your own email server or use a provider that's not listed above which provides you with SMTP credentials, you can configure Bonfire to use that:

```
MAIL_BACKEND=smtp
MAIL_SERVER=your_smtp_server
MAIL_PORT=587
MAIL_USER=your_smtp_username
MAIL_PASSWORD=your_smtp_password
MAIL_FROM=email@instance.domain
MAIL_SSL=true
```

Notes: 
- `MAIL_PORT` defaults to `587` if not specified.
- `MAIL_SSL` defaults to `true`, set to `false` if server does not support SSL.

#### Sendmail
- Built into many Unix-like operating systems
```
MAIL_BACKEND=sendmail
MAIL_SERVER=/path/to/sendmail
# MAIL_ARGS=
MAIL_QMAIL=true_or_false
MAIL_FROM=email@instance.domain
```

Notes: 
- `MAIL_SERVER` defaults to `/usr/bin/sendmail` if not specified.
- `MAIL_ARGS` defaults to `-N delay,failure,success` if not specified.
- While sendmail can send mail directly (similar to the default behaviour), it can be set up to hand off emails to a local or remote SMTP server for delivery.
- Using sendmail usually provides more control and logging capabilities compared to the default direct SMTP delivery.

#### Postal
- Self-hosted email delivery platform
- Website: [postalserver.io](https://docs.postalserver.io)
```
MAIL_BACKEND=postal
MAIL_KEY=your_postal_api_key
MAIL_BASE_URI=https://your_postal_server_api.uri/
MAIL_FROM=email@instance.domain
```


## Copyright and License

Copyright (c) 2024 Bonfire Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see <https://www.gnu.org/licenses/>.
