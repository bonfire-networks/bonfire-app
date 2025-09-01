# Setup Tutorial

## Overview 

This guideline goes through the steps to set up a server and prerequisites for running a Bonfire instance for your community 🔥 ✨

The general steps are:
1. 🖥 Get a Server 
2. Set up domain-name, mail and DNS
   1. 👉 Domain name or subdomain on an existing domain 
   2. 📧 Set up mail 
   3. 🌐 DNS set up 
3. 🔥 Install Bonfire

## Walkthrough

### 1. Get a server

Bonfire can be setup on any server (dedicated/virtual/VPS/docker/homelab). Hetzner is a common choice to set up a [dedicated](https://www.hetzner.com/sb) or [virtual server](https://www.hetzner.com/cloud/) in EU.  

- Hardware requirement: 8GB+ RAM
- If you don't already have an ssh key, create one on your computer in terminal. The command varies but is usually `ssh keygen`
	- If you are new to ssh: 
- Activate firewalls *after* completing set up to minimize the potential issues for trouble shooting  

> [!Tip] Protip
> Save your SSH private and public keys (and password if you set one) in a password manager to minimize the chance of getting locked-out of your server!

> [!note] Note
> It is also possible to store data (such as uploaded images) in a cloud service rather than directly on your server (through any provider that supports the S3 API), but this isn't necessary to do up front.


### 2. Set up a domain, Mail and DNS 

##### 2.1 Domain name
The domain name can be a new domain like *yourdomain.net* that you purchase or a sub-domain of an existing site you already have such as *sub.yourdomain.net*. All users on your instance will have the domain you select as part of their username, such as `@user@sub.yourdomain.net`

In this step we can use a domain name service such as namecheap, which was used in this tutorial.

> [!tip] Protip
>  It takes around 24h to propagate among the DNS servers so give yourself plenty of time to account for potential DNS set-up errors.

##### 2.2 Set up mail - SPF, DMARK, etc

Mailgun is one of manny services offering a free email routing service for up to 1 account. See [this page for alternatives and how to configure them](https://docs.bonfirenetworks.org/Bonfire.Mailer.html).

> [!Tip] Protip
> Your domain used for the bonfire instance (e.g. yourdomain.net or social.yourdomain.net) must be different from one for the email domain (e.g. email.yourdomain.net)

Follow [this guideline](https://documentation.mailgun.com/docs/mailgun/quickstart-guide/quickstart/) for info on how to set up your Mailgun account. 

> [!tip] Protip
>  On Mailgun the EU / US interfaces are separate, make sure you stick to the same interface (little flag at the top)

##### 2.3 Add the details to DNS

On the DNS service (usually using the domain name provider's dashboard) we will need to set up our details for the server and the email service. 

The following outline is a general list of required details. the values are placeholders to show what it might look like. Brackets, such as `[insert]`, indicate that you add your own characters. 

First you need DNS pointing the domain to the server:
	- **IPv4** as an A record
		- host: `@` to use `yourdomain.net` or e.g. `social` if you wanted to use `social.yourdomain.net`
		- value: `[XXX.XXX.XXX.XXX]` (IP address of your server)
	- **Wildcard** DNS as an A record 
		- host: `*` to use `yourdomain.net` or e.g. `*.social` if you wanted to use `social.yourdomain.net`
		- value: `[XXX.XXX.XXX.XXX]` (IP address of your server)
        
It may looking something like this: 
![Screenshot 2025-06-27 at 15.14.06](https://hackmd.io/_uploads/B1RVP72Elg.png)

For email, use the info provided by the email service you set up (make sure you set up **all** of the different things provided, such as CNAME, DMARK, DKIM, and SPF, otherwise emails may not be delivered or end up in spam), here is an example of what it may look like when using mailgun. 
        
	- **CNAME** record 
		- host: `email.[sub]`
		- value: `eu.mailgun.org.` 
	- **DMARC TXT** Record 
		- host: `dmarc.[sub]`
		- value: `v=DMARC1; p=none; pct=100; fo=1; ri=3600; rua=mailto :fcf2` etc...
	- **SPF TXT** Record 
		- host:  `[sub]`
		- value: `v=spf1 include:mailgun.org ~all`


###### Optionally
-  add IPv6 as AAAA Record (*notice, different DNS require different formats for IPv6)*	- add wildcard DNS as an AAAA record with * as the hostname and the server IPv6
- MX set up if you want to be able to receive emails as well


> [!Tip] Protip
>  IPv6 sometimes messes things up. Optionally you can skip IPv6 to start with and add later once IPv4 is securely running.


### 3. Final Step: Install Bonfire

Once you have completed the above steps and your server, domain, mail, and DNS are ready, proceed to the [Hosting Guide](./DEPLOY.md) for detailed instructions on installing and configuring Bonfire using your preferred method (Co-op Cloud, Docker, bare-metal, etc).

