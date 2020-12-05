--Find the _previous_ seat (where one neighbour is missing, but the next exists),
--and from that, calculate our own seatId.
SELECT seatId+1
FROM boarding_passes bp
WHERE
    EXISTS (SELECT * FROM boarding_passes WHERE seatId = bp.seatId+2)
    AND NOT EXISTS (SELECT * FROM boarding_passes WHERE seatId = bp.seatId+1)
;