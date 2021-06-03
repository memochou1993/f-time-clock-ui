<template>
  <v-row
    justify="center"
    no-gutters
  >
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
                type="password"
                outlined
                ref="password"
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
                v-model="email"
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
              value="1"
            />
            <v-form
              v-model="fulfilled"
            >
              <v-text-field
                v-model="token"
                :rules="[(v) => !!v]"
                autocomplete="off"
                autofocus
                hide-details
                label="Token"
                outlined
                ref="token"
                class="mb-6"
              />
              <v-row
                no-gutters
              >
                <v-col
                  class="text-center"
                >
                  <v-btn
                    color="primary"
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
                    :disabled="loading || !fulfilled"
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
            <v-row
              class="mb-6"
            >
              <v-col
                :cols="12"
                :md="6"
                :lg="4"
                class="pb-0"
              >
                <v-date-picker
                  v-model="date"
                  :first-day-of-week="1"
                  color="primary"
                  full-width
                />
              </v-col>
              <v-col
                :cols="12"
                :md="6"
                :lg="4"
                class="pb-0"
              >
                <v-time-picker
                  color="primary"
                  format="24hr"
                  full-width
                />
              </v-col>
              <v-col
                :cols="12"
                :md="6"
                :lg="4"
                class="pb-0"
              >
                <v-card></v-card>
              </v-col>
            </v-row>
            <v-row
              no-gutters
            >
              <v-col
                class="text-left"
              >
                <v-btn
                  color="primary"
                  outlined
                  @click="detach()"
                >
                  Detach
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
                  Attach
                </v-btn>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
    </template>
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
import AppAlert from '@/components/AppAlert.vue';
import AppStepper from '@/components/AppStepper.vue';

const STATUS_DETACHED = '1';
const STATUS_ATTACHED = '2';
const STATUS_VERIFIED = '3';

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
    date: (new Date()).toISOString().substring(0, 10), // FIXME
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
            text: `${res.status} ${res.statusText}`,
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
            text: `${res.status} ${res.statusText}`,
          });
          this.setToken('');
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
            text: `${res.status} ${res.statusText}`,
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
  },
};
</script>

<style lang="scss" scoped>
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
    height: 400px;
  }
}
</style>
