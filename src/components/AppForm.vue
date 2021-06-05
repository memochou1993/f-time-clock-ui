<template>
  <v-row
    justify="center"
    no-gutters
  >
    <v-col
      :cols="12"
    >
      <div
        class="text-center text-h5 font-weight-re mb-6 cursor-default"
      >
        Time Clock
      </div>
    </v-col>
    <template
      v-if="isStatusDetached"
    >
      <v-col
        :cols="12"
        :sm="8"
        :md="6"
        :lg="4"
      >
        <v-card>
          <v-card-text
            class="pa-6"
          >
            <AppStepper
              value="1"
            />
            <v-form
              v-model="fulfilled"
            >
              <v-text-field
                v-model="username"
                :rules="[(v) => !!v]"
                autocomplete="off"
                autofocus
                hide-details
                label="Username"
                outlined
                ref="username"
                class="mb-6"
              />
              <v-text-field
                v-model="password"
                :rules="[(v) => !!v]"
                autocomplete="off"
                hide-details
                label="Password"
                outlined
                ref="password"
                type="password"
                class="mb-6"
              />
              <v-text-field
                v-model="id"
                :rules="[(v) => !!v]"
                autocomplete="off"
                hide-details
                label="User ID"
                outlined
                ref="id"
                class="mb-6"
              />
              <v-text-field
                v-model="company"
                :rules="[(v) => !!v]"
                autocomplete="off"
                hide-details
                label="Company"
                outlined
                ref="company"
                class="mb-6"
              />
              <v-text-field
                v-show="false"
                v-model="email"
                :rules="[(v) => !!v]"
                autocomplete="off"
                hide-details
                label="Email"
                outlined
                ref="email"
                class="mb-6"
              />
              <v-row
                no-gutters
              >
                <v-col
                  class="text-center"
                >
                  <v-btn
                    :disabled="loading || !fulfilled"
                    :loading="loading"
                    color="primary"
                    depressed
                    type="submit"
                    @click="attach()"
                  >
                    Submit
                  </v-btn>
                </v-col>
              </v-row>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </template>
    <template
      v-if="isStatusAttached"
    >
      <v-col
        :cols="12"
        :sm="8"
        :md="6"
        :lg="4"
      >
        <v-card>
          <v-card-text
            class="pa-6"
          >
            <AppStepper
              value="2"
            />
            <v-form
              v-model="fulfilled"
            >
              <v-text-field
                v-model="token"
                autocomplete="off"
                autofocus
                hide-details
                label="Token"
                outlined
                ref="token"
                type="password"
                class="mb-6"
              />
              <v-row
                no-gutters
              >
                <v-col
                  class="text-center"
                >
                  <v-btn
                    color="grey lighten-1"
                    depressed
                    outlined
                    @click="detach()"
                  >
                    Reset
                  </v-btn>
                </v-col>
                <v-spacer></v-spacer>
                <v-col>
                  <v-btn
                    :disabled="loading || !token"
                    color="primary"
                    depressed
                    type="submit"
                    @click="verify()"
                  >
                    Verify
                  </v-btn>
                </v-col>
              </v-row>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </template>
    <template
      v-if="isStatusVerified"
    >
      <v-col
        :cols="12"
      >
        <v-card>
          <v-card-text
            class="pa-6"
          >
            <v-row>
              <v-col
                :cols="12"
                :sm="6"
                :lg="4"
              >
                <v-date-picker
                  v-model="date"
                  :allowed-dates="allowedDates"
                  :events="eventIcons"
                  :max="maxDate"
                  :min="minDate"
                  color="primary"
                  full-width
                />
              </v-col>
              <v-col
                :cols="12"
                :sm="6"
                :lg="4"
              >
                <v-time-picker
                  v-model="time"
                  :allowed-hours="allowedHours"
                  color="primary"
                  format="24hr"
                  full-width
                  @change="clickHour()"
                />
              </v-col>
              <v-col
                :cols="12"
                :sm="12"
                :lg="4"
              >
                <v-card
                  outlined
                  class="mb-6"
                >
                  <v-card-text
                    class="pa-0"
                  >
                    <v-list
                      class="py-0"
                    >
                      <template
                        v-for="(action, i) in actions"
                      >
                        <v-list-item
                          :key="i"
                          class="pl-0"
                        >
                          <v-btn
                            v-if="findEvent(filteredEvents, action.type)"
                            :disabled="!isAllowedDate"
                            color="orange"
                            outlined
                            class="ma-6"
                            @click="destroyEvent(findEvent(filteredEvents, action.type))"
                          >
                            <span
                              v-text="action.name"
                            />
                          </v-btn>
                          <v-btn
                            v-else
                            :disabled="!isAllowedDate"
                            color="orange"
                            class="ma-6"
                            @click="createEvent(action.type)"
                          >
                            <span
                              v-text="action.name"
                            />
                          </v-btn>
                          <template
                            v-if="findEvent(filteredEvents, action.type)"
                          >
                            <v-list-item-content>
                              <v-list-item-title
                                class="text-h6"
                              >
                                <span
                                  v-text="formatDate(findEvent(filteredEvents, action.type).date)"
                                  :key="i"
                                  class="title font-weight-light"
                                />
                              </v-list-item-title>
                            </v-list-item-content>
                          </template>
                        </v-list-item>
                        <v-divider
                          v-if="i < actions.length -1"
                          :key="`divider-${i}`"
                        />
                      </template>
                    </v-list>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
            <v-row>
              <v-col
                class="text-left"
              >
                <v-btn
                  color="grey lighten-1"
                  outlined
                  @click="detach()"
                >
                  Reset
                </v-btn>
              </v-col>
              <v-spacer></v-spacer>
              <v-col
                class="text-right"
              >
                <v-btn
                  color="primary"
                  depressed
                  @click="attach()"
                >
                  Apply
                </v-btn>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
    </template>
    <v-col
      :cols="12"
    >
      <div
        class="caption text-center grey--text text--disabled mt-6"
      >
        <span
          v-text="`© ${new Date().getFullYear()} Memo Chou`"
          class="cursor-pointer"
          @click="explore()"
        />
      </div>
    </v-col>
    <AppAlert
      v-if="message"
      :color="message.success ? 'success' : 'error'"
      :text="message.text"
      @onClose="setMessage(null)"
    />
  </v-row>
</template>

<script>
import axios from '@/plugins/axios';
import moment from 'moment';
import AppAlert from '@/components/AppAlert.vue';
import AppStepper from '@/components/AppStepper.vue';

const STATUS_DETACHED = '1';
const STATUS_ATTACHED = '2';
const STATUS_VERIFIED = '3';

const ACTION_CLOCK_IN = 'CLOCK_IN';
const ACTION_CLOCK_OUT = 'CLOCK_OUT';

const HOUR_CLOCK_IN = '09';
const HOUR_CLOCK_OUT = '18';

export default {
  name: 'AppForm',
  components: {
    AppAlert,
    AppStepper,
  },
  data: () => ({
    status: STATUS_DETACHED,
    fulfilled: false,
    username: '',
    password: '',
    id: '',
    company: '',
    email: '',
    token: '',
    date: moment().format('YYYY-MM-DD'),
    time: '',
    events: [],
    actions: [
      {
        name: 'IN',
        type: ACTION_CLOCK_IN,
      },
      {
        name: 'OUT',
        type: ACTION_CLOCK_OUT,
      },
    ],
    message: null,
    loading: false,
  }),
  computed: {
    isStatusDetached() {
      return this.status === STATUS_DETACHED;
    },
    isStatusAttached() {
      return this.status === STATUS_ATTACHED;
    },
    isStatusVerified() {
      return this.status === STATUS_VERIFIED;
    },
    payload() {
      return {
        username: this.username,
        company: this.company,
        email: this.email,
        id: this.id,
        token: this.token,
        events: this.events,
      };
    },
    filteredEvents() {
      return this.events.filter((e) => moment(e.date).isSame(moment(this.date), 'day'));
    },
    isAllowedDate() {
      return this.allowedDates(this.date);
    },
    allowedDates() {
      return (v) => [1, 2, 3, 4, 5].includes(moment(v).days());
    },
    allowedHours() {
      return [Number(HOUR_CLOCK_IN), Number(HOUR_CLOCK_OUT)];
    },
    maxDate() {
      return moment().add(1, 'weeks').endOf('week').format('YYYY-MM-DD');
    },
    minDate() {
      return moment().format('YYYY-MM-DD');
    },
    eventIcons() {
      return (date) => {
        const filter = (action) => this.events.filter((e) => e.action === action).some((e) => moment(e.date).isSame(moment(date), 'day'));
        const colorize = (bool) => (bool ? 'orange' : '');
        return [
          colorize(filter(ACTION_CLOCK_IN)),
          colorize(filter(ACTION_CLOCK_OUT)),
        ];
      };
    },
  },
  watch: {
    company(value) {
      this.setEmail(`${this.username}@${value}.com`);
    },
    username(value) {
      this.setEmail(`${value}@${this.company}.com`);
    },
    payload(value) {
      localStorage.setItem('payload', JSON.stringify(value));
    },
  },
  created() {
    this.restore();
  },
  mounted() {
    this.clickMinute();
    this.setRandomTime(HOUR_CLOCK_IN, 0, 30);
  },
  methods: {
    setStatus(status) {
      if ([STATUS_DETACHED, STATUS_ATTACHED, STATUS_VERIFIED].includes(status)) {
        this.status = status;
        localStorage.setItem('status', status);
        return;
      }
      this.status = STATUS_DETACHED;
      localStorage.setItem('status', STATUS_DETACHED);
    },
    setUsername(username) {
      this.username = username;
    },
    setPassword(password) {
      this.password = password;
    },
    setId(id) {
      this.id = id;
    },
    setCompany(company) {
      this.company = company;
    },
    setEmail(email) {
      this.email = email;
    },
    setToken(token) {
      this.token = token;
    },
    setDate(date) {
      this.date = date;
    },
    setTime(time) {
      this.time = time;
    },
    setEvents(events) {
      this.events = events;
    },
    setMessage(message) {
      this.message = message;
    },
    setLoading(value) {
      this.loading = value;
    },
    restore() {
      const payload = JSON.parse(localStorage.getItem('payload'));
      this.setUsername(payload?.username || '');
      this.setCompany(payload?.company || '');
      this.setEmail(payload?.email || '');
      this.setId(payload?.id || '');
      this.setToken(payload?.token || '');
      this.setEvents(payload?.events || []);
      this.setStatus(localStorage.getItem('status') || STATUS_DETACHED);
    },
    attach() {
      this.setLoading(true);
      axios({
        method: 'post',
        url: '/api/attach',
        data: {
          ...this.payload,
          password: this.password,
        },
      })
        .then((res) => {
          this.setMessage({
            success: true,
            text: `Request succeeded with status code ${res.status}`,
          });
          if (this.isStatusDetached) {
            this.setStatus(STATUS_ATTACHED);
            this.$nextTick(() => this.$refs.token?.focus());
          }
        })
        .catch((e) => {
          this.setMessage({
            success: false,
            text: e.message,
          });
          switch (e?.response?.status) {
            case 400:
              this.setStatus(STATUS_DETACHED);
              break;
            case 401:
              this.setStatus(STATUS_ATTACHED);
              this.$nextTick(() => this.$refs.token?.focus());
              break;
            case 403:
              this.setStatus(STATUS_ATTACHED);
              this.$nextTick(() => this.$refs.token?.focus());
              break;
            default:
              break;
          }
        })
        .finally(() => {
          this.setPassword('');
          this.setLoading(false);
        });
    },
    detach() {
      this.setLoading(true);
      axios({
        method: 'post',
        url: '/api/detach',
        data: {
          ...this.payload,
          password: this.token,
        },
      })
        .then((res) => {
          this.setMessage({
            success: true,
            text: `Request succeeded with status code ${res.status}`,
          });
          this.setToken('');
          this.setEvents([]);
          this.setStatus(STATUS_DETACHED);
          this.$nextTick(() => this.$refs.username?.focus());
        })
        .catch((e) => {
          this.setMessage({
            success: false,
            text: e.message,
          });
          switch (e?.response?.status) {
            case 401:
              this.setStatus(STATUS_ATTACHED);
              this.$nextTick(() => this.$refs.token?.focus());
              break;
            case 404:
              this.setToken('');
              this.setStatus(STATUS_DETACHED);
              this.$nextTick(() => this.$refs.username?.focus());
              break;
            default:
              break;
          }
        })
        .finally(() => {
          this.setLoading(false);
        });
    },
    verify() {
      this.setLoading(true);
      const { payload } = this;
      axios({
        method: 'post',
        url: '/api/verify',
        data: payload,
      })
        .then((res) => {
          this.setMessage({
            success: true,
            text: `Request succeeded with status code ${res.status}`,
          });
          this.setStatus(STATUS_VERIFIED);
        })
        .catch((e) => {
          this.setMessage({
            success: false,
            text: e.message,
          });
          switch (e?.response?.status) {
            case 401:
              this.setStatus(STATUS_ATTACHED);
              this.$nextTick(() => this.$refs.token?.focus());
              break;
            case 404:
              this.setToken('');
              this.setStatus(STATUS_DETACHED);
              this.$nextTick(() => this.$refs.username?.focus());
              break;
            default:
              break;
          }
        })
        .finally(() => {
          this.setLoading(false);
        });
    },
    findEvent(events, action) {
      return events.find((e) => e.action === action);
    },
    createEvent(action) {
      this.events.push({
        id: +new Date(),
        action,
        date: `${this.date}T${this.time}:00+08:00`,
      });
      if (action === ACTION_CLOCK_IN) {
        this.setRandomTime(HOUR_CLOCK_OUT, 30, 60);
      }
      if (action === ACTION_CLOCK_OUT) {
        this.setRandomTime(HOUR_CLOCK_IN, 0, 30);
      }
    },
    destroyEvent(event) {
      this.events.splice(this.events.findIndex((e) => e.id === event.id), 1);
    },
    setRandomTime(hour, minMinute, maxMinute) {
      const random = (min, max) => Math.floor(Math.random() * (max - min) + min);
      this.setTime(moment(`${hour}:${random(minMinute, maxMinute)}`, 'HH:mm').format('HH:mm'));
    },
    formatDate(date) {
      return moment(date).format('HH:mm');
    },
    clickHour() {
      const hour = this.$el.querySelector('.v-time-picker-title__time .v-picker__title__btn:first-child');
      if (hour) {
        hour.click();
      }
    },
    clickMinute() {
      const minute = this.$el.querySelector('.v-time-picker-title__time .v-picker__title__btn:last-child');
      if (minute) {
        minute.click();
      }
    },
    explore() {
      window.open('https://github.com/memochou1993/time-clock', '_blank', 'noopener noreferrer');
    },
  },
};
</script>

<style lang="scss" scoped>
.cursor-default {
  cursor: default;
}

.cursor-pointer {
  cursor: pointer;
}

::v-deep {
  .theme--dark.v-stepper {
    background: inherit;
  }
  .v-text-field--outlined {
    &.v-input--is-focused,
    &.v-input--has-state {
      fieldset {
        border: 1px solid currentColor;
      }
    }
  }
  .v-picker {
    height: 390px;
    .v-btn--active:hover::before,
    .v-btn--active::before {
      opacity: 0 !important;
    }
  }
  .v-time-picker-clock__item {
    &:after,
    &before,
    span {
      cursor: pointer;
    }
    height: 32px;
    width: 32px;
  }
  .v-picker__title {
    height: 100px;
  }
  .v-time-picker-title__time {
    .v-picker__title__btn,
    span {
      font-size: 50px;
    }
  }
}
</style>
