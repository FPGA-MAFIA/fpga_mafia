---
marp: true
---

<p align="center">
  <img src="Aspose.Words.1e88255e-f250-4d7c-ba99-2f8b3844a485.001.png" alt="Image">
</p>



Faculty Of Engineering

The Hardware Design Laboratory



<div style="text-align: center;">
  <h1 style="font-size: 70px;"><strong>HAS</strong></h1>
</div>
High Level Specification


<p align="center">
  <h1><strong>Cache Architecture for the Mesh project</strong></h1>
</p>

### Noam Sabban

Fourth year project towards a bachelor's degree in Engineering

Advisor: Amichai Ben-David


# <a name="_toc1813475768"></a>**Author**
*If you contribute to this document, please add your name here so the reader will know who to go to if they have questions.*

|**Author**|**Email address**|
| :- | :- |
|**Amichai Ben-David**|**abendavid@nvidia.com**|
|**Noam Sabban**|**Sabban.noam@gmail.com**|
|||


# <a name="_toc1008912806"></a>**Revision History**
*Please supply the date, author, and a brief description of major revisions of this document.*

|**Revision**|**Date**|**Author**|**Description**|
| :- | :- | :- | :- |
|**0.01**|24/11/2022|Amichai Ben-David|Initial Draft – skeleton & overview|
||04/01/2023|Noam Sabban|Added Merge Buffer description|
||17/01/2023|Noam Sabban|Interfaces parameters update|
|||||
|||||




# **Contents**
[Author	](#_toc1813475768)

[Revision History	](#_toc1008912806)

[1 List of Figures	](#_toc549082651)

[2	Open Issues](#_toc1653690369)

[3	Introduction](#_toc497346094)

[3.1	References](#_toc1831783840)

[3.2	Glossary](#_toc287259830)

[4	Overview](#_toc914283578)

[4.1	Top Level Cache diagram](#_toc1099454153)

[4.2	Cache Parameters](#_toc1601460835)

[4.3	Cache Size & Address bits](#_toc677317680)

[4.3.1	Tag Array structure](#_toc44808337)

[4.3.2	Cache Data Array structure](#_toc903703668)

[4.4	Top-Level-Interface](#_toc1485040757)

[4.5	Core Interface](#_toc1902304017)

[4.6	FM Interface](#_toc1894377982)

[4.7	Pipe Interface](#_toc1374780217)

[5	High Level Block Description](#_toc1781685860)

[5.1	Transaction Queue (TQ)](#_toc216915204)

[5.2	Pipe](#_toc1128226896)

[5.3	Tag Array](#_toc768632131)

[5.4	Data Cache Array](#_toc248060331)

[6	High level Transaction Flows](#_toc1779312326)

[6.1	Evicting Cache-Line](#_toc968886961)

[6.2	Core Write Hit](#_toc129901246)

[6.3	CORE WRITE MISS](#_toc1298113976)

[6.4	Core Read Hit](#_toc762484656)

[6.5	Core Read Miss.](#_toc1368926867)

[6.6	Stall](#_toc86425335)

[6.7	FSM Errors](#_toc1574458668)

[6.8	MRU](#_toc1429789757)

[6.9	FILL](#_toc73125539)

[7	Merge Buffer Behavior](#_toc1444127171)

[7.1	Read After Write (same Cache Line, word hit)](#_toc761038880)

[7.2	Read After Write (same Cache Line, word Miss)](#_toc1647958394)

[7.3	Write After Write (Same Cache Line, same/different word)](#_toc1077647588)

[7.4	Write After Read (Same Cache Line, Same/different Word)](#_toc854682441)

[7.5	Read After Read (Same Cache Line, Same/different Word)](#_toc2125413379)

[8	Assumption & Assertions](#_toc2054752113)

[8.1	Core Interface Assumption:](#_toc1030114760)

[8.2	Far Memory Interface Assumption:](#_toc826535799)

[9	Appendix](#_toc93555976)

[9.1	Future Features](#_toc1491728741)

[10	ABD Notes:](#_toc1529489236)



# **1. List of Figures**
[Figure 1 - Top Level DC_CACHE Diagram	6](#_toc120191342)

[Figure 3- Tag Array Table	8](https://d.docs.live.net/6977cd27928fbf9b/Desktop/BIU%20-%20mesh/HAS_Cache.docx#_Toc120191343)

[*Figure 2- Data Array*	8](https://d.docs.live.net/6977cd27928fbf9b/Desktop/BIU%20-%20mesh/HAS_Cache.docx#_Toc120191344)


# **2. Open Issues**
- Partial Write
- Fill
- Pre-fetch
- Responses Ordering
- Latency
- Number of outstanding requests


# **3. Introduction**
  ## **3.1 References**
- <TODO> presentation
- <TODO> IAS
- <TODO> Repository

## **3.2 Glossary**

|**Acronym/Term**|**Definition/Meaning**|
| :-: | :- |
|**FM**|Far Memory|
|**FILL**||
|**WB**|Write Back – Data that we send from the Cache to the FM.|
|**CL**|Cache Line|
|**WORD**||
|**Flush**||
|**TAG**|address [19:12] - bits we compare in the “4-way associative” cache. |
|**SET**|address [11:4] - the tag array “entry” pointer|
|**Offset**|address [3:0] – 16-byte offset, four 4-byte words. Not used in CL granularity.|
|**WAY**||
|**TAG\_ARRAY**||
|**MB**|Merge Buffer -  Buffer in our TQ that will store partial data|
|<a name="_int_mjycew0y"></a>**TQ**|Transaction Queue|
|<a name="_int_vhu9oylu"></a>**FSM**|Finite State Machine|
|**LU**|Lookup|
|**Dirty Evict**|When modified data in the cache is evicted – write back (WB) to FM |
|**Clean Evict**|When non-modified in the cache is evicted -  write back (WB) to FM|
|**Silent Evict**|When non-modified in the cache is evicted -  no write back (WB) to FM|
|**MRU**|Most recently used|
|<a name="_int_d2qhauxh"></a>**LRU**|Least recently used|
|**DU\_CACHE**|Design-Camp CACHE|
|**DUT**|Device Under Test|

<p align="center"> Table 1: List of Acronyms/Terminology/glossary</p>

# <a name="_toc205576272"></a><a name="_toc914283578"></a>**4. Overview**
This HAS (High-Level-Architecture-Specification) will describe the Cache <a name="_int_ep1dzelp"></a>DUT
The cache is a 4-way associative, 16KB Cache.
The Cache structure:

- **Transaction Queue (TQ)** – allocates entries for each read/write transaction. 
  Manage the requests life cycle until it completes in an FSM.
- **Pipe** – manages the tag array lookup (LU) & Cache access.
- **Tag Array** – memory structure that holds the tag information. (Tag, valid, modified, mru, fill)
  Accessible by reading the full set. {SET} as the LU address. [^1]
- **Data Cache Array** – memory structure that holds the Cache Data.
  Accessible using the by reading single CL. {WAY, SET} as the Address[^2]

In abstract view, the cache neighboring blocks:

- Core - sends read/write requests.
- Far Memory (FM) – Cache read misses & modified write back (WB) for “dirty evict<a name="_int_whspgelr"></a>”.
## <a name="_toc473224587"></a><a name="_toc1099454153"></a>**4.1 Top Level Cache diagram** 

<p align="center">
  <img src="Aspose.Words.1e88255e-f250-4d7c-ba99-2f8b3844a485.002.png" alt="Image">
</p>

<p align="center"><a name="_toc117104404"></a><a name="_toc120191342"></a>Figure 1 - Top Level DC_CACHE Diagram</p>

## <a name="_toc1234491379"></a><a name="_toc1601460835"></a>**4.2 Cache Parameters**

|**Parameters**|**Value**|
| :-: | :-: |
|**NUM\_TQ\_ENTRY**|8|
|**WORD\_WIDTH**|32|
|**NUM\_WORDS\_IN\_CL**|4|
|**CL\_WIDTH**|128 (WORD\_WIDTH x NUM\_WORDS\_IN\_CL)|
|**OFFSET\_WIDTH**|4 (CL\_WIDTH = 16 Bytes)|
|**SET\_ADRS\_WIDTH**|8 (address [11:4])|
|**TAG\_WIDTH**|8 (address [19:12])|
|**ADDRESS\_WIDTH**|20 (OFFSET\_WIDTH + SET\_ADRS\_WIDTH + TAG\_WIDTH)|
|**CL\_ADRS\_WIDTH**|16 (SET\_ADRS\_WIDTH + TAG\_WIDTH)|
|**NUM\_WAYS**|4|
|**TAG\_INDICATION**|(Valid + Modified + MRU)|
|**REQ\_ID\_WIDTH**|8 (Up to 255 requests can be served out-of-order)<br>The REQ\_ID is assigned a value according to order with wrap-around.|
|**TQ\_ID\_WIDTH**|3 (Up to 8 TQ entries, outstanding FM READ requests)|

<p align="center"> Table 2- cache parameters</p>



## <a name="_toc1095580426"></a><a name="_toc677317680"></a>**4.3 Cache Size & Address bits**
**Address Size:** 
Address [19:0] = {tag [7:0], set [7:0], offset [3:0]};
  ### <a name="_toc1655948451"></a><a name="_toc44808337"></a>**4.3.1 Tag Array structure**
**Tag Array Size:**	
(#SET) x (NUM\_WAYS) x (TAG\_WIDTH)
256x4x8 = 8192 bit = 1024 Byte = 2^10 **= 1024 Byte of “TAG”**

(#SET) x (NUM\_WAYS) x (TAG\_INDICATION)
256x4x4 = 4096 bits = 512 Byte = 2^9 = **512 Byte of “TAG\_INDICATION”**

**Total Tag Array size:** (tags + indications))**
` `1024+512 = 1536 Byte -> 1.5KB
### <a name="_toc1157786503"></a><a name="_toc903703668"></a>**4.3.2 Cache Data Array structure**
**Cache Line Size:**
CL [127:0] = {word3[31:0], word2[31:0], word1[31:0], word0[31:0]}. 

**Data Cache Array Size:**
(#SET) x (NUM\_WAYS) x (CL\_WIDTH)
256x4x128 = 131072 bit = 16384 Byte = 2^14 = **16KB of Cache Data**


![](Aspose.Words.1e88255e-f250-4d7c-ba99-2f8b3844a485.003.png)

## <a name="_toc1974910992"></a><a name="_toc1485040757"></a>**4.4 Top-Level-Interface**

|**Adhoc interface**|
| :- |
|`   `input   logic       clk,|
|input   logic       rst,|

## <a name="_toc1930335004"></a><a name="_toc1902304017"></a>**4.5 Core Interface**

|**Output stall**||
| :- | :- |
|`    `logic  stall,              |TQ is full, cannot accept new request|
|**input core2cache\_req**||
|`    `logic         valid;||
|`    `t\_req\_id      req\_id;||
|`    `t\_opcode      opcode; |RD\_OP & WR\_OP|
|`    `t\_address     address;||
|`    `t\_word        data;||
|**output cache2core\_rsp**||
|`    `logic        valid;||
|`    `t\_adress     address;||
|`    `t\_word       data;||
|`    `t\_req\_id     req\_id;  ||
|||

## <a name="_toc878682083"></a><a name="_toc1894377982"></a>**4.6 FM Interface**

|**output  cache2fm\_req\_q3**||
| :- | :- |
|`    `logic           valid; ||
|`    `t\_tq\_id         tq\_id ;||
|`    `t\_address       address;||
|`    `t\_cl            data;||
|`    `t\_fm\_req\_op     opcode ;||
|    ||
|` `**input fm2cache\_rd\_rsp**    ||
|`    `logic       valid;||
|`    `t\_tq\_id     tq\_id; |// must match the original rd\_req tq\_id|
|`    `t\_cl        data;||

##
##
##

## <a name="_toc1374780217"></a>**4.7 Pipe Interface**

|**output  pipe\_lu\_req\_q1**||
| :- | :- |
|`    `logic            valid;||
|`    `t\_lu\_opcode      lu\_op ;||
|`    `t\_tq\_id          tq\_id;||
|`    `t\_address        address;||
|`    `t\_cl             cl\_data        ||
|`    `t\_word           data||
|` `**input pipe\_lu\_rsp\_q3**||
|`    `logic            valid;||
|`    `t\_lu\_result      lu\_result;||
|`    `t\_lu\_opcode      lu\_opcode;||
|`    `t\_tq\_id          tq\_id;||
|`    `t\_cl             data;||
|`    `// t\_offset      offset;||
|`    `t\_address        address;||


# <a name="_toc1755039306"></a><a name="_toc1781685860"></a>**5. High Level Block Description**
## <a name="_toc157919810"></a><a name="_toc216915204"></a>**5.1 Transaction Queue (TQ)** 
The transaction Queue has <NUM\_TQ\_ENTRY> entries. 
Each entry has Buffer & FSM (Finite State Machine).
Buffer - Holds the Data, Address, req\_id of each request.
FSM 	- will manage the requests life cycle.
Common Finite State Machine Flow:

- **Write Hit:**          S\_IDLE -> S\_LU\_CORE->S\_ IDLE
- **Write Miss:**       S\_IDLE -> S\_LU\_CORE->S\_MB\_WAIT\_FILL -> S\_MB\_FILL\_READY -> S\_ IDLE
- **Read Hit:****    	      S\_IDLE -> S\_LU\_CORE->S\_ IDLE
- **Read Miss:** 	       S\_IDLE -> S\_LU\_CORE->S\_MB\_WAIT\_FILL -> S\_MB\_FILL\_READY -> S\_ IDLE
## <a name="_toc362446169"></a><a name="_toc1128226896"></a>**5.2 Pipe**
The “Pipe” is a 3-stage pipeline that manages the tag array lookup (LU) & Cache access.

- Stage 1: Tag Array Look up (Read)
- Stage 2: Tag Compare, Tag-Array Update, Cache Read
- Stage 3: Cache Write, FM Write Back [(Dirty evict)](#_evicting_cache-line) & FM Read - Fill [(Cache miss)](#_core_read_miss. ), LU results to TQ.
## <a name="_toc2002927206"></a><a name="_toc768632131"></a>**5.3 Tag Array**
The Tag Array is a memory structure that holds the Tags & Indication – Valid, Modified, MRU, Fill.
The “Set” (Index) is the Tag Array read pointer. 
A Lookup will return the entire “Set<a name="_int_yon3np9n"></a>”.
Each “set” is 4-ways, meaning each Lookup will compare 4 TAG & their Indications with the Tag we are looking up.
The Tag Indication will update according to the Lookup request.

- MRU – A tag hit will update the Way MRU indication.
  ` `Micro architecture decision for the exact MRU arbitration scheme.
- Modified – A Write request will update the Modified indication
- Fill – A Read miss will set the “Fill” Indication. A Fill Hit with LU\_FILL opcode will reset the “Fill” Indication.
## <a name="_toc1970387951"></a><a name="_toc248060331"></a>**5.4 Data Cache Array**
The Data Cache is a memory structure that holds the Cache-Line (CL) Data.
Each access reads a “single” CL - Meaning reading a single “way<a name="_int_6lwusvnw"></a>”. 
The exact location in the Cache is determined by the ‘Way hit’ in the Tag Array Lookup.
Data Array pointer = {Set[7:0],Way[1:0]}
||||
| :- | :-: | -: |

# <a name="_toc1967356741"></a><a name="_toc1779312326"></a>**6. High level Transaction Flows**
In this chapter will describe the high-level transaction Flow.
## <a name="_toc52774757"></a><a name="_toc968886961"></a>**6.1 Evicting Cache-Line**
- **Silent Evict:** When de-allocating a non-modified CL without notifying the FM.
- **Clean Evict:** When de-allocating a non-modified CL and Writing it Back to FM.
- ***Note:** In this Cache Architecture, we do not support “Clean evict<a name="_int_qcv0rjgk"></a>”.*
- **Dirty Evict:** When de-allocating a modified CL from the Cache, and writing it back to FM.
## <a name="_toc222509515"></a><a name="_toc129901246"></a>**6.2 Core Write Hit**
core2cache\_req writes that were accepted to the TQ, and hit the tag array will result in cache write by hitting an existing CL 
## <a name="_toc1298113976"></a>**6.3 CORE WRITE MISS**
core2cache\_req writes that were accepted to the TQ, may miss the tag array, and will result in cache write by allocating a new way in the Cache.
If the allocated way (the “victim”) was modified, send a Dirty Evict Write Back (WB) to FM.
If the allocated way (the “victim”) was clean (non-modified), simply do a Silent Evict.

## <a name="_toc409398135"></a><a name="_toc762484656"></a>**6.4 Core Read Hit**
core2cache\_req read CL that **hit** the cache, will respond with data on the “cache2core\_rsp” interface in deterministic 2 Cycle Latency. There is no need to “allocate” a new way in the cache, and no “victim” to send as WB to FM.
## <a name="_toc1161000507"></a><a name="_toc1368926867"></a><a name="_ref101430185"></a>**6.5 Core Read Miss** 
core2cache\_req read CL that **misses** the cache will eventually respond with data on the “cache2core\_rsp” interface. 

1. A stall will happen, stopping new requests from the core temporarily.
2. The miss will trigger a “cache2fm\_rd\_req\_q3,” which will send the read request to the Far-Memory (FM) & eventually respond with the fm2cache\_rd\_rsp – also known as “Fill”.
   The response from FM has two destinations:
- Cache: 	The fm2cache\_rd\_rsp will “fill” the allocated Cache Way
- Core: 	The fm2cache\_rd\_rsp will be sent as a “cache2core\_rsp” to serve the origin 		core2cache\_req.
## <a name="_toc1847471893"></a><a name="_toc86425335"></a>**6.6 Stall**
Stall is a situation where we do not allow new requests from the core temporarily, causing a delay in the execution of the program. Our cache will enter stall mode in two scenarios
The first will be when our TQ is full, it will set the “stall” signal to the core, stopping new requests from being sent.
The second is in the case of a Read Miss. This will result in a stall, as the processing of the request is temporarily stopped while the data is retrieved from main memory.
## **6.7 Re-Issue buffer**
We saw that in the case of “Read Miss<a name="_int_ajpkpurn"></a>”, the Stall will be set, and this will temporarily stop the processing of request. 

This means, we support a single “outstanding” core read miss request

In case of Back2Back request, In the q2 cycle we set the Stall due to the Read miss, but Q1 already was sent from core->cache.
This Q1 request must be rejected by TQ & Pipe.
Yet, we do not want to lose That rejected request.
We Will save them and take care of them after the stall is unset. (Note: during the stall we are not expecting any new request from Core.)
For that purpose, we will use the “re-issue buffer<a name="_int_rk6wy9uj"></a>”. It will store the last request that arrived during the stall.
Once the Read fill response arrives and sent to Core, we will check if the Re-issue buffer is empty. If it is, we have nothing more to do. If it is not empty, it will mean we have a request that is waiting to be handled and we will re-issue it to our TQ & pipe from this specific buffer.

## <a name="_toc2088317011"></a><a name="_toc1574458668"></a>**6.8 FSM Errors**
Entering the “error state” in the transaction queue (TQ) State Machine is an “**uncorrectable** **error”** that can cause data corruption & coherent inconsistency.
This state is for debugging and security to ensure the Cache is not abused.
Entering the “error state” is un-recoverable and will cause a “Blue-Screen of Death<a name="_int_bbuhwfs8"></a>”.
## <a name="_toc1429789757"></a>**6.9 MRU**
In this project we will use the Pseudo Most Recently Used (P-MRU) replacement policy to determine which entry to remove when our cache is full and a new entry needs to be added. In this policy, the newest entry is placed at the head of the cache and whenever it is full, the item at the end of the cache is the one that will be replaced. It will provide an efficient way of managing our cache memory ensuring that the most frequently used data is readily available in the cache.
To be more specific we are using Bit-PLRU, it will store one status bits per way. Every access to a way in our set will set its MRU-bits to 1 indicating the way was recently used. Whenever the last 0 bit of a set’s status bits is set to 1, all other bits are reset to 0. 
## <a name="_toc73125539"></a>**6.10 FILL**
In case of miss, the cache will send a fill request to the Far Memory to bring the corresponding Cache-Line to the cache.
“<a name="_int_7l1xpihz"></a>fill\_modified” bit will inform us that the actual fill is happening because of a write miss and that the specific CL will be updated with the new word
“fill\_rd” bit will inform us that the fill is happening because of a read miss and that we need to return the value to the core after we bring it in the cache. It will also be set in case of read after write to the same CL. As we have already explained in this case the read miss will not send a new fill request so this bit will inform the <a name="_int_yzf1nbyu"></a>tq to also send the read response after the fill (of the write request) arrive.
# <a name="_toc1444127171"></a>**7. Merge Buffer Behavior** 
In this chapter we will explain the Merge Buffer behavior through different cases

The <a name="_int_nz7q838o"></a>merge\_buffer is a buffer in our TQ that will store partial data during the time we are waiting for the Cache Line Data to be filled by the Far Memory. 
Every entry in the TQ is linked to a Merge Buffer entry then we need to take care that every request to the same Cache-Line will never allocate a new entry if there already is an entry in the TQ for that specific Cache-Line.
## <a name="_toc761038880"></a>**7.1 Read After Write (same Cache Line, word hit)**
In this case, if the Write request got a Miss, it will update the Far Memory (fill request) that we need a data and update the TQ that he got a Miss. 
The partial write data (no a full CL) will be stored in the Merge Buffer until we get the fill response from FM. 
During this time, if the TQ get a Read Request to the same Cache Line + same word offset:

1. We know that the lookup will get a Miss from the pipe. 
1. TQ merge buffer will response with TQ Hit to this specific word (Word Hit).
1. It will indicate to the pipe that there is no need for a fill from Far Memory. (Cancel the fill)
1. It will read it straight from the Merge Buffer and return it to Core. Make sure the Merge buffer response will be the correct cycle (Q3) of the pipe lookup that we already know will miss.

This will happen only if the TQ is not in S\_FILL\_LU state. If it is, the data will be read from the Tag Array and not directly from the Merge Buffer.
## <a name="_toc1647958394"></a>**7.2 Read After Write (same Cache Line, word Miss)**
Just like in the last case the Write request got a Miss and is waiting for the data from Far Memory and stored the partial write to the Merge Buffer.
During this time, we are getting a Read Request to the same CacheLine but this time to another word. In this case, contrary to the last one, we cannot read the data from the Merge Buffer because we got Word Miss. 
1\. TQ will send a Stall signal to the core so it will wait for the data to be filled. 
2\. Once the TQ gets the Far Memory response for the Write request and will fill our Cache Line in the Merge Buffer, this line will be written to the Data Cache Array with an indication “rd\_fill\_rsp”.
3\. The pipe will write the fill + return the data to the TQ as if there was a read hit so it will be sent as a Read response to the Core in Q3.

## <a name="_toc1077647588"></a>**7.3 Write After Write (Same Cache Line, same/different word)**
For this case, we have already tried to Write to the same Cache Line but now we want to make another Write to a different word in that Cache Line. The first write will miss and send the fill request to FM + allocate a merge\_buffer entry.
The second Write request will enter the pipe, get a Write Miss indication but this time it will not make a Far Memory request because we have an indication from the TQ that we have a “Merge Buffer Hit” which mean we have already a Line in the Merge Buffer for this CacheLine. The partial Write data will be written to that line in the Merge buffer.
Once the Far Memory response to the Merge Buffer, the Cache Line will be filled (without overriding the `new` word writes)
The TQ entry will become a fill candidate, and eventually will win the arbitration to fill the cache though the Pipe.
## <a name="_toc854682441"></a>**7.4 Write After Read (Same Cache Line, Same/different Word)**
Currently In our architecture, there is no issue with Write after Read due to the fact the incase of a read miss, we stall any new requests from the core until the first miss is resolved. 

## <a name="_toc2125413379"></a>**7.5 Read After Read (Same Cache Line, Same/different Word)**
Currently In our architecture, there is no issue with Raed after Read due to the fact the incase of a read miss, we stall any new requests from the core. until the first miss is resolved.

# <a name="_toc2123724073"></a>**8. Verification** 
In this section we will write a list of scenarios and points we want to cover

- Rd after Rd to same cache-line: the first read request should miss but the second one should hit.
- Read after Write to same CL: expecting same behavior as above.
- Multiple writes then multiple reads, all to same CL: we are expecting a miss for the first write request which will send a fill, for the others they can miss but should not send a new fill request, all the read requests should hit.
- Write b2b to the same CL: we expect miss for the two write request but a fill only for the first one. Read requests after a small delay to check the write data is read. 

# <a name="_toc2054752113"></a>**9. Assumption & Assertions**
## <a name="_toc1951742785"></a><a name="_toc1030114760"></a>**9.1 Core Interface Assumption:**
- Core will not send Read/Write requests when Cache asserts the Stall signals
- All Reads & Writes are Word aligned
- Writes can be sb sh or sw
- Reads can be lb, lh or lw
- Core cannot Reject or Stall Read Responses
## <a name="_toc2063968789"></a><a name="_toc826535799"></a>**9.2 Far Memory Interface Assumption:**
- The FM Read response latency is not deterministic 
- FM Cannot reject/Stall
  1) “Dirty Evict” (Write modified Data to FM)
  2) Read miss. (Read Request from Cache to FM)
  This means there is no need for an "ack.accept" interface between cache <-> FM
# <a name="_toc121115370"></a><a name="_toc93555976"></a>**10. Appendix**
## <a name="_toc949245735"></a><a name="_toc1491728741"></a>**10.1 Future Features** 
- Partial CL Write – “Word Enable”
- Support same CL access without reject & preserve ordering
  - Read After Write
  - Write After Read
  - Write After Write
  - Read After Read -> No issue. (Single Core System, Data Cannot change)
# <a name="_toc1529489236"></a>**11. ABD Notes:**
I gave some thought in to how to resolve the back2back request and this is what I produced:

- Each tq entry can serve multiple writes that are to the same CL by writing the writes in order into the merge buffer.
- In case the CL hits in the pipe, there is no issue – forwarding units & read modify write will make sure the tag array & the data array will have the correct cohirent data.
- In case the second write was Back2Back, we don’t want to deallocate the TQ entry after the first write, so we can add a counter that count how many writes are merged into the same CL, and the counter decrements with every lu hit response from pipe, as long as the State is in S\_LU\_CORE & the counter is not back to 0, the entry will not go back to IDLE.

Once the Entry is set as a Read Request entry, (due to a read lookup hit the same address), We will not merge any new request to the same entry.

This is why this would work:

The new Read request enters the cache in Cycle Q1.

In Q2 the TQ allocation in visable + we have the tag array results from the lookup.

Incase Q2 is a tag miss, the new request in Q1 will be canceled and stored in the “re-issue-buffer" - and will not affect any existing entries.
Only once the read miss is resolved with the fill, the “re-issue-buffer" will re-send the new lookup and allocate the tq array / merge into an existing TQ entry.

Need to make sure we correctly handle the case of a read after write back2back with Cacheline miss. - make sure we send a single FM fill request.(TODO)

A read request that has the same CL as existing TQ entry that is also marked as read will NOT merge!!! And will allocate a new TQ entry. (a TQ entry can serve multiple writes, but a single READ!)


Need to think about this: Once an entry is set as “Read<a name="_int_ypnewna7"></a>”, writes cannot merge more writes into it?

- If the read missed, we will cancel the write, and re-issue it once the read miss is resolved.
- If the read hit, the pipe lookup will return the data, will dealloc the entry.
  In parallel a different entry will handle the write. (which we expect to hit – just like the read before it)
- Not expecting to have 2 entries with the same cl & both are wait fill.. we can have 2 entries with same CL if we know that there was cache hit.
- The order is promised due to the request intering the pipe in order. And if they all hit there is no issue. One there is a miss, no new request is being served in the pipe. So again- order is preserved.

||||
| :- | :-: | -: |


[^1]: When accessing the tag array, we read/write full set, which has 4 ways. Each with Tag + indication.
[^2]: When accessing the Data cache array, we read/write single CL – which is a single way in the Set.