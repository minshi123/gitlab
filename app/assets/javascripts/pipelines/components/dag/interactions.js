import * as d3 from 'd3';
import { lightenDarkenColor } from './drawing_utils';

const highlightIn = 1;
const highlightOut = 0.2;

export const highlightLinks = (d, i, n) => {
  const currentLink = d3.select(n[i]);

  /* Higlight selected link, de-emphasize others */
  d3.selectAll('.dag-link:not(.live)').style('stroke-opacity', highlightOut);
  currentLink.style('stroke-opacity', highlightIn);

  /* Do the same to related nodes */
  d3.selectAll('.dag-node:not(.live)')
    .attr('stroke', '#f2f2f2')

  d3.select(`#${d.source.uid}`)
    // .classed('live', true)
    .attr('stroke', d.source.color)

  d3.select(`#${d.target.uid}`)
    // .classed('live', true)
    .attr('stroke', d.target.color)

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
  /* highlight correct links */
  parentLinks.forEach((id) => {
    d3.select(`#${id}`)
      .classed('live', true)
      .style('stroke-opacity', highlightIn);
  })

  /* highlight correct nodes */
  parentNodes.forEach((id) => {
    d3.select(`#${id}`)
      .classed('live', true)
      .attr('stroke', d => d.color)
  });

  /* de-emphasize everything else */
  d3.selectAll('.dag-link:not(.live)').style('stroke-opacity', highlightOut);

  d3.selectAll('.dag-node:not(.live)')
      .attr('stroke', '#f2f2f2')
}

const restorePath = (parentLinks, parentNodes, baseOpacity) => {

  parentLinks.forEach((id) => {
    d3.select(`#${id}`)
      .style('stroke-opacity', baseOpacity)
      .classed('live', false);
  });

  parentNodes.forEach((id) => {
    d3.select(`#${id}`)
      .classed('live', false)
  });

  d3.selectAll('.dag-link:not(.live)')
    .style('stroke-opacity', baseOpacity);

  d3.selectAll('.dag-node:not(.live)')
    .attr('stroke', d => d.color)
}

export const restoreLinks = (baseOpacity, d, i, n) => {
  const currentLink = d3.select(n[i]);


  // if there exist live links, reset to highlight out / pale
  // otherwise, reset to base

  console.log(d3.selectAll('.live').empty());

  if (d3.selectAll('.live').empty()) {
    d3.selectAll('.dag-link')
      .style('stroke-opacity', baseOpacity);

    d3.selectAll('.dag-node')
      .attr('stroke', d => d.color)

    return;
  }


  d3.selectAll('.dag-link:not(.live)').style('stroke-opacity', highlightOut);

  d3.selectAll('.dag-node:not(.live)')
    .attr('stroke', '#f2f2f2');

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
