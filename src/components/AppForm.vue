<template>
  <v-row
    justify="center"
    no-gutters
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
          <v-stepper
            v-show="isDetached || isAttached"
            :value="status"
            alt-labels
            flat
          >
            <v-stepper-header>
              <v-stepper-step
                step="1"
              />
              <v-divider></v-divider>
              <v-stepper-step
                step="2"
              />
            </v-stepper-header>
          </v-stepper>
          <v-form>
            <v-row
              no-gutters
            >
              <template
                v-if="isDetached"
              >
                <v-col>
                  <v-text-field
                    v-model="username"
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
                    autocomplete="off"
                    hide-details
                    label="User ID"
                    outlined
                    ref="id"
                    class="mb-6"
                  />
                  <v-text-field
                    v-model="company"
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
                </v-col>
              </template>
              <template
                v-if="isAttached"
              >
                <v-col>
                  <v-text-field
                    v-model="token"
                    autocomplete="off"
                    autofocus
                    hide-details
                    label="Token"
                    outlined
                    ref="token"
                    class="mb-6"
                  />
                </v-col>
              </template>
              <template
                v-if="isVerified"
              >
                <v-col>
                  <v-card
                    outlined
                  >
                    <v-date-picker
                      v-model="date"
                      :first-day-of-week="1"
                      color="primary"
                      full-width
                      class="mb-6"
                    />
                  </v-card>
                </v-col>
              </template>
            </v-row>
            <v-row
              no-gutters
            >
              <template
                v-if="isDetached"
              >
                <v-col
                  class="text-center"
                >
                  <v-btn
                    :disabled="loading"
                    color="primary"
                    depressed
                    type="submit"
                    @click="attach()"
                  >
                    Attach
                  </v-btn>
                </v-col>
              </template>
              <template
                v-if="isAttached"
              >
                <v-col
                  class="text-center"
                >
                  <v-btn
                    :disabled="loading"
                    color="primary"
                    depressed
                    type="submit"
                    @click="verify()"
                  >
                    Verify
                  </v-btn>
                </v-col>
              </template>
              <template
                v-if="isVerified"
              >
                <v-col
                  class="text-left"
                >
                  <v-btn
                    :disabled="loading"
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
                    :disabled="loading"
                    color="primary"
                    depressed
                    @click="attach()"
                  >
                    Attach
                  </v-btn>
                </v-col>
              </template>
            </v-row>
          </v-form>
        </v-card-text>
      </v-card>
      <v-snackbar
        v-model="alert"
        :color="message.success ? 'success' : 'error'"
        text
      >
        <span
          v-text="message.text"
        />
      </v-snackbar>
    </v-col>
  </v-row>
</template>

<script>
import axios from '@/plugins/axios';

const STATUS_DETACHED = '1';
const STATUS_ATTACHED = '2';
const STATUS_VERIFIED = '3';

export default {
  name: 'AppForm',
  data: () => ({
    status: STATUS_DETACHED,
    username: '',
    password: '',
    id: '',
    company: '',
    email: '',
    token: '',
    date: (new Date()).toISOString().substring(0, 10), // FIXME
    alert: false,
    message: '',
    loading: false,
  }),
  computed: {
    isDetached() {
      return this.status === STATUS_DETACHED;
    },
    isAttached() {
      return this.status === STATUS_ATTACHED;
    },
    isVerified() {
      return this.status === STATUS_VERIFIED;
    },
    payload() {
      return {
        company: this.company,
        credentials: {
          username: this.username,
        },
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
    alert(value) {
      if (!value) {
        this.setMessage('');
      }
    },
    message(value) {
      if (value) {
        this.setAlert(true);
      }
    },
  },
  created() {
    this.restore();
  },
  methods: {
    setStatus(status) {
      this.status = status;
      if (status) {
        localStorage.setItem('status', status);
      }
    },
    setUsername(username) {
      this.username = username;
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
    setAlert(alert) {
      this.alert = alert;
    },
    setMessage(message) {
      this.message = message;
    },
    setLoading(value) {
      this.loading = value;
    },
    restore() {
      const payload = JSON.parse(localStorage.getItem('payload'));
      this.setCompany(payload?.company || '');
      this.setUsername(payload?.credentials?.username || '');
      this.setEmail(payload?.email || '');
      this.setId(payload?.id || '');
      this.setStatus(localStorage.getItem('status') || STATUS_DETACHED);
    },
    attach() {
      this.setLoading(true);
      const { payload } = this;
      payload.credentials.password = this.password;
      axios({
        method: 'post',
        url: '/api/attach',
        data: payload,
      })
        .then((res) => {
          this.setMessage({
            success: true,
            text: res.statusText,
          });
          this.setStatus(STATUS_ATTACHED);
        })
        .catch((e) => {
          if (e?.response?.status === 400) {
            this.setMessage({
              success: false,
              text: e.message,
            });
          }
          if (e?.response?.status === 401) {
            this.setStatus(STATUS_ATTACHED);
          }
          if (e?.response?.status === 403) {
            this.setStatus(STATUS_ATTACHED);
          }
        })
        .finally(() => {
          this.setLoading(false);
        });
    },
    detach() {
      // TODO
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
          if (e?.response?.status === 404) {
            this.setStatus(STATUS_DETACHED);
          }
        })
        .finally(() => {
          this.setLoading(false);
        });
    },
  },
};
</script>
