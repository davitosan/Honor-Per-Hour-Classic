####**HPH**
In classic, for the current day, the client only tracks and displays the number of honorable kills, not the amount of honor gained. This is a problem for players who need to accurately track their weekly honor for ranking purposes.

HPH solves this by capturing each honor message and calculating the real honor gained, taking diminishing returns into account as per [this](https://us.forums.blizzard.com/en/wow/t/alterac-valley-adjustments-incoming/422125).

HPH is an extension of [this](https://wago.io/KSACGWwO9) WA.

####**Server Reset time**
By default the addon resets at 8.00 ST. This can be changed in interface settings (/hph):

![alt text](https://i.imgur.com/YFyDNpp.png "GeneralSettings")

####**Calculated Honor vs. Real Honor**
There will always be a small rounding error in the calculated honor which be can be bounded as: error = |real honor - calculated honor| &lt; HKs, where HKs are all less than 100 pct. DR'd honorable kills

"Honor: 33.905 ± (e &lt; 560)" then means that your weekly honor has been calculated to be 33.905, but that your real honor is somewhere between 33.345 and 34.465.

For stacking purposes we have found that this is negligible in regards to how much RP each person gains.

Error displaying is turned off by default but can be turned on in options.

####**Data loss**
Like any other addon, using alt + f4 or otherwise crashing your game to exit it either intentionally or not, will result in loss of data, and in incorrect "Honor Today". Exiting the game normally or using /reload will save your data.

####**Features**
**Honor and Session stats**  

![alt text](https://i.imgur.com/7HBBRtx.png "MainWindow") ![alt text](https://i.imgur.com/BsaYR8y.png "MainWindow2")

**Combat summary**  

![alt text](https://i.imgur.com/Ht46z7k.png "HonorMsg") ![alt text](https://i.imgur.com/m5Qpxb6.png "HonorMsg2")  

**Mouseover DR tracking**  

![alt text](https://i.imgur.com/OMXeihY.png "Tooltip") ![alt text](https://i.imgur.com/Nvpy1qA.png "Tooltip2")  

**Blizzard UI fix**  

![alt text](https://i.imgur.com/lctFnQq.png "HonorTab")  

**Other**  
/hph search &lt;name&gt;  (prints how many times you have killed a player today)  
/hph week (prints last 7 days calculated honor)
