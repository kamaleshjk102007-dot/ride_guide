const estimateWaitTime = (ride, peopleInQueue) => {
  if (!ride || !ride.capacity || !ride.duration) {
    return 0;
  }

  const cyclesNeeded = Math.ceil(peopleInQueue / ride.capacity);
  return cyclesNeeded * ride.duration;
};

module.exports = { estimateWaitTime };
