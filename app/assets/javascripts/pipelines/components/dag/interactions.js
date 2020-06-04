import * as d3 from 'd3';
import { LINK_SELECTOR, NODE_SELECTOR, IS_HIGHLIGHTED } from './constants';

const highlightIn = 1;
const highlightOut = 0.2;

const getCurrent = (i, n) => d3.select(n[i]);
const currentIsLive = (i, n) => getCurrent(i, n).classed(IS_HIGHLIGHTED);
const getOtherLinks = () => d3.selectAll(`.${LINK_SELECTOR}:not(.${IS_HIGHLIGHTED})`);
const getNodesNotLive = () => d3.selectAll(`.${NODE_SELECTOR}:not(.${IS_HIGHLIGHTED})`);

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
  const currentLink = getCurrent(i, n);
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
      .classed(IS_HIGHLIGHTED, true);
  })

  /* highlight correct nodes */
  parentNodes.forEach((id) => {
    foregroundNodes(d3.select(`#${id}`))
      .classed(IS_HIGHLIGHTED, true);
  });
}

const restorePath = (parentLinks, parentNodes, baseOpacity) => {

  parentLinks.forEach((id) => {
    renewLinks(d3.select(`#${id}`), baseOpacity)
      .classed(IS_HIGHLIGHTED, false);
  });

  parentNodes.forEach((id) => {
    d3.select(`#${id}`)
      .classed(IS_HIGHLIGHTED, false)
  });

  if (d3.selectAll(`.${IS_HIGHLIGHTED}`).empty()) {
    renewLinks(getOtherLinks(), baseOpacity);
    renewNodes(getNodesNotLive());
    return;
  }

  backgroundLinks(getOtherLinks());
  backgroundNodes(getNodesNotLive());

}

export const restoreLinks = (baseOpacity, d, i, n) => {

  /* in this case, it has just been clicked */
  if (currentIsLive(i, n)) {
    return;
  }

  /*
    if there exist live links, reset to highlight out / pale
    otherwise, reset to base
  */

  if (d3.selectAll(`.${IS_HIGHLIGHTED}`).empty()) {
    renewLinks(d3.selectAll(`.${LINK_SELECTOR}`), baseOpacity);
    renewNodes(d3.selectAll(`.${NODE_SELECTOR}`));
    return;
  }

  backgroundLinks(getOtherLinks());
  backgroundNodes(getNodesNotLive());
}

export const toggleLinkHighlight = (baseOpacity, d, i, n) => {

  if (currentIsLive(i, n)) {
    restorePath([d.uid], [d.source.uid, d.target.uid], baseOpacity)
    return;
  }

  highlightPath([d.uid], [d.source.uid, d.target.uid])

}

export const togglePathHighlights = (baseOpacity, d, i, n) => {

  const parentLinks = getAllLinkAncestors(d);
  const parentNodes = getAllNodeAncestors(d);
  const currentNode = getCurrent(i, n);

  /* if this node is already live, make it unlive and reset its path */
  if (currentIsLive(i, n)) {
    currentNode.classed(IS_HIGHLIGHTED, false);
    restorePath(parentLinks, parentNodes, baseOpacity);
    return;
  }

  highlightPath(parentLinks, parentNodes);
}
