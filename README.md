# HomeAssistant
Installing and configuring Home Assistant

### Prerequisites
<li>Basic computer/Raspberry Pi know how</li>
<li>Working Raspberry Pi</li>
<li>SSH access to Raspberry Pi</li>
<li>Access to Internet</li>

The script is self contained and fetches necessary files from github repo.

### Installing
#### Simple Installation
For installation, run below commands from your Pi terminal (or SSH session) :

<code>wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/DNS_Over_HTTPS_Via_Cloudflare.sh</code>

Update the permissions on the downloaded file using:

<code>chmod 755 DNS_Over_HTTPS_Via_Cloudflare.sh</code>

Now run below script and follow prompts:

<code>./DNS_Over_HTTPS_Via_Cloudflare.sh  | tee DNS_Over_HTTPS_Via_Cloudflare.log</code>
