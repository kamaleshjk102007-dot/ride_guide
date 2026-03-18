const Visitor = require("../models/Visitor");

const VISITOR_ID_PREFIX = "VST";
const VISITOR_ID_START = 1001;

const formatVisitorId = (sequence) => `${VISITOR_ID_PREFIX}${sequence}`;

const getNextVisitorIdentity = async () => {
  const latestVisitor = await Visitor.findOne({ visitor_sequence: { $exists: true } })
    .sort({ visitor_sequence: -1 })
    .select("visitor_sequence");
  const nextSequence = latestVisitor?.visitor_sequence != null
    ? latestVisitor.visitor_sequence + 1
    : VISITOR_ID_START;

  return {
    visitor_sequence: nextSequence,
    visitor_id: formatVisitorId(nextSequence)
  };
};

const assignVisitorIdentity = async (visitor) => {
  if (visitor.visitor_id && visitor.visitor_sequence) {
    return visitor;
  }

  const identity = await getNextVisitorIdentity();
  visitor.visitor_sequence = identity.visitor_sequence;
  visitor.visitor_id = identity.visitor_id;
  if (!visitor.status) {
    visitor.status = "Active";
  }
  await visitor.save();
  return visitor;
};

module.exports = { assignVisitorIdentity, getNextVisitorIdentity, formatVisitorId, VISITOR_ID_START };
