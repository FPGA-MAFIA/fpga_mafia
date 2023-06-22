# CACHE MAS - Mirco Architecture Specification

## Introduction


## Lookup Pipe priority
In the common case we priorities the Core request over the TQ fill request.
But when we have a rd_miss, the Core is being stalled, So all fill request are getting served.
Once we are done serving the miss request fill, the core will get the priority again.

## Cache hit merge buffer
Each TQ Can be set with a write indication bit and a read indication bit.  
*Write indication bit:*  
The write indication bit will trigger the modified bit for the Cache Line once that tq writing to the cache.  

*Read indication bit:*
When a write requests hits an existing TQ merge buffer entry.


## Read response to core paths
1. simple LU read hit
2. LU miss:
   - Option 1: LU miss initiates the FW request (a fill request)
   - Option 2: LU miss merged into an existing TQ entry that is already serving a FW fill request. 
     Note: it was a write entry, which now is setting the rd_indication bit
## The tq_rd_indication


## B2B write request in pipe
We allow B2B write requests.
The Th Write request will all be merged into the same TQ merge buffer entry.
if its a "stream" of "hits" the TQ will stay valid until the last write request is served.
This is done using the "pipe_lu_rsp_q3.wr_match_in_pipe" to indicate that there are write requests in pipe.
Which means that the same TQ is still serving write request.


