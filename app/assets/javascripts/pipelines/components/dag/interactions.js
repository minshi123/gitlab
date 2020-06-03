import * as d3 from 'd3';
import { LINK_SELECTOR, NODE_SELECTOR } from './constants';

const highlightIn = 1;
const highlightOut = 0.2;

const getOtherLinks = () => d3.selectAll(`.${LINK_SELECTOR}:not(.live)`);
const getNodesNotLive = () => d3.selectAll(`.${NODE_SELECTOR}:not(.live)`);

const backgroundLinks = (selection) => {
  return selection.style('stroke-opacity', highlightOut);
}

const backgroundNodes = (selection) => {
  return selection.attr('stroke', '#f2f2f2')
}

const foregroundLinks = (selection) => {
  return selection.style('stroke-opacity', highlightIn);
}

const foregroundNodes = (selection) => {
  return selection.attr('stroke', d => d.color)
}

const renewLinks = (selection, baseOpacity) => {
  return selection.style('stroke-opacity', baseOpacity);
}

const renewNodes = (selection) => {
  return selection.attr('stroke', d => d.color)
}

export const highlightLinks = (d, i, n) => {
  const currentLink = d3.select(n[i]);
  const currentSourceNode = d3.select(`#${d.source.uid}`);
  const currentTargetNode = d3.select(`#${d.target.uid}`);

  /* Higlight selected link, de-emphasize others */
  backgroundLinks(getOtherLinks());
  foregroundLinks(currentLink);

  /* Do the same to related nodes */
  backgroundNodes(getNodesNotLive());
  foregroundNodes(currentSourceNode);
  foregroundNodes(currentTargetNode);

}

const getAllLinkAncestors = (node) => {

  if (node.targetLinks) {
    return node.targetLinks.flatMap((n) => {
      return [n.uid, ...getAllLinkAncestors(n.source)]
    });
  }

  return [];
};

const getAllNodeAncestors = (node) => {

  let allNodes = [];

  if (node.targetLinks) {
    allNodes = node.targetLinks.flatMap((n) => {
      return getAllNodeAncestors(n.source);
    });
  }

  return [...allNodes, node.uid];
};

const highlightPath = (parentLinks, parentNodes) => {

  /* de-emphasize everything else */
  backgroundLinks(getOtherLinks());
  backgroundNodes(getNodesNotLive());

  /* highlight correct links */
  parentLinks.forEach((id) => {
    foregroundLinks(d3.select(`#${id}`))
      .classed('live', true);
  })

  /* highlight correct nodes */
  parentNodes.forEach((id) => {
    foregroundNodes(d3.select(`#${id}`))
      .classed('live', true);
  });
}

const restorePath = (parentLinks, parentNodes, baseOpacity) => {

  parentLinks.forEach((id) => {
    renewLinks(d3.select(`#${id}`), baseOpacity)
      .classed('live', false);
  });

  parentNodes.forEach((id) => {
    d3.select(`#${id}`)
      .classed('live', false)
  });

  renewLinks(getOtherLinks(), baseOpacity);
  renewNodes(getNodesNotLive());
}

export const restoreLinks = (baseOpacity) => {

  /*
    if there exist live links, reset to highlight out / pale
    otherwise, reset to base
  */

  if (d3.selectAll('.live').empty()) {
    renewLinks(d3.selectAll(`.${LINK_SELECTOR}`), baseOpacity);
    renewNodes(d3.selectAll(`.${NODE_SELECTOR}`));
    return;
  }

  backgroundLinks(getOtherLinks());
  backgroundNodes(getNodesNotLive());
}

export const togglePathHighlights = (baseOpacity, d, i, n) => {

  const parentLinks = getAllLinkAncestors(d);
  const parentNodes = getAllNodeAncestors(d);
  const currentNode = d3.select(n[i]);

  // if this node is already live, make it unlive / highlight off
  if (currentNode.classed('live')) {
    currentNode.classed('live', false);
    restorePath(parentLinks, parentNodes, baseOpacity);
    return;
  }

  highlightPath(parentLinks, parentNodes);
}
