import Vue from 'vue';
import { __ } from '~/locale';
import { GlColumnChart } from '@gitlab/ui/dist/charts';

document.addEventListener('DOMContentLoaded', () => {
  const languagesContainer = document.getElementById('js-languages-chart');
  const monthContainer = document.getElementById('js-month-chart');
  const weekdayContainer = document.getElementById('js-weekday-chart');
  const hourContainer = document.getElementById('js-hour-chart');

  const LANGUAGE_CHART_HEIGHT = 300;

  const reorderWeekDays = (weekDays, firstDayOfWeek = 0) => {
    if (firstDayOfWeek === 0) {
      return weekDays;
    }

    return Object.keys(weekDays).reduce((acc, dayName, idx, arr) => {
      const reorderedDayName = arr[(idx + firstDayOfWeek) % arr.length];

      return {
        ...acc,
        [reorderedDayName]: weekDays[reorderedDayName],
      };
    }, {});
  };

  // eslint-disable-next-line no-new
  new Vue({
    el: languagesContainer,
    components: {
      GlColumnChart,
    },
    data() {
      return {
        chartData: JSON.parse(languagesContainer.dataset.chartData),
      };
    },
    computed: {
      seriesData() {
        return { full: this.chartData.map(d => [d.label, d.value]) };
      },
    },
    render(h) {
      return h(GlColumnChart, {
        props: {
          data: this.seriesData,
          xAxisTitle: __('Used programming language'),
          yAxisTitle: __('Percentage'),
          xAxisType: 'category',
        },
        attrs: {
          height: LANGUAGE_CHART_HEIGHT,
        },
      });
    },
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: monthContainer,
    components: {
      GlColumnChart,
    },
    data() {
      return {
        chartData: JSON.parse(monthContainer.dataset.chartData),
      };
    },
    computed: {
      seriesData() {
        const data = [];
        Object.keys(this.chartData).forEach(key => data.push([key, this.chartData[key]]));
        return { full: data };
      },
    },
    render(h) {
      return h(GlColumnChart, {
        props: {
          data: this.seriesData,
          xAxisTitle: __('Day of month'),
          yAxisTitle: __('No. of commits'),
          xAxisType: 'category',
        },
      });
    },
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: weekdayContainer,
    components: {
      GlColumnChart,
    },
    data() {
      return {
        chartData: JSON.parse(weekdayContainer.dataset.chartData),
      };
    },
    computed: {
      seriesData() {
        const data = [];
        const weekDays = reorderWeekDays(this.chartData, gon.first_day_of_week);
        Object.keys(weekDays).forEach(key => data.push([key, weekDays[key]]));
        return { full: data };
      },
    },
    render(h) {
      return h(GlColumnChart, {
        props: {
          data: this.seriesData,
          xAxisTitle: __('Weekday'),
          yAxisTitle: __('No. of commits'),
          xAxisType: 'category',
        },
      });
    },
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: hourContainer,
    components: {
      GlColumnChart,
    },
    data() {
      return {
        chartData: JSON.parse(hourContainer.dataset.chartData),
      };
    },
    computed: {
      seriesData() {
        const data = [];
        Object.keys(this.chartData).forEach(key => data.push([key, this.chartData[key]]));
        return { full: data };
      },
    },
    render(h) {
      return h(GlColumnChart, {
        props: {
          data: this.seriesData,
          xAxisTitle: __('Hour (UTC)'),
          yAxisTitle: __('No. of commits'),
          xAxisType: 'category',
        },
      });
    },
  });
});
