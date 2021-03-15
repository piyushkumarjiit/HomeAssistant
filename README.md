# HomeAssistant
Installing and configuring Home Assistant Supervised

### Prerequisites
<li>Basic computer/Raspberry Pi know how</li>
<li>Working Raspberry Pi</li>
<li>SSH access to Raspberry Pi</li>
<li>Access to Internet</li>

The script is self contained and fetches necessary files from github repo.

### Installing
#### Simple Installation
For installation, run below commands from your Pi terminal (or SSH session) :

<code>wget https://raw.githubusercontent.com/piyushkumarjiit/HomeAssistant/main/install_hass_supervised.sh</code>

Update the permissions on the downloaded file using:

<code>chmod 755 install_hass_supervised.sh</code>

Now run below script and follow prompts:

<code>./install_hass_supervised.sh |& tee install_hass_supervised.log</code>
