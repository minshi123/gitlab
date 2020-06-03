import * as d3 from 'd3';
import { lightenDarkenColor } from './drawing_utils';

const highlightIn = 1;
const highlightOut = 0.2;

export const highlightLinks = (d, i, n) => {
  const currentLink = n[i];

  /* Higlight selected link, de-emphasize others */
  d3.selectAll('.dag-link:not(.live)').style('stroke-opacity', highlightOut);
  d3.select(currentLink).style('stroke-opacity', highlightIn);

  /* Do the same to nodes */
  d3.select(`#${d.source.uid}`)
    .classed('live', true)
    .attr('stroke', d.source.color)

  d3.select(`#${d.target.uid}`)
    .classed('live', true)
    .attr('stroke', d.target.color)

  d3.selectAll('.dag-node:not(.live)')
    .attr('stroke', '#f2f2f2')

}

export const restoreLinks = (baseOpacity, d, i, n) => {
  const currentLink = d3.select(n[i]);

  if (!currentLink.classed('live')) {
    d3.selectAll('.dag-link:not(.live)')
      .style('stroke-opacity', baseOpacity);

    d3.selectAll('.dag-node:not(.live)')
      .attr('stroke', d => d.color)
  }

  d3.select(`#${d.source.uid}`)
    .classed('live', false)

  d3.select(`#${d.target.uid}`)
    .classed('live', false)
}
