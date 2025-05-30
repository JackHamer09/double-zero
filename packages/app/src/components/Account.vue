<template>
  <div class="head-block">
    <Breadcrumbs :items="breadcrumbItems" />
    <SearchForm class="search-form" />
  </div>
  <Title
    v-if="account?.address"
    :title="t('accountView.title')"
    :value="account?.address"
  />
  <Spinner v-else size="md" />
  <div class="tables-container">
    <div class="account-tables-container">
      <div>
        <AccountTable
          class="account-table"
          :loading="pending"
          :account="account"
        />
      </div>
      <div>
        <BalanceTable
          class="balance-table"
          :loading="pending"
          :balances="account?.balances"
        >
          <template #not-found>
            <EmptyState>
              <template #image>
                <div class="balances-empty-icon">
                  <img
                    v-if="authorized"
                    src="/images/empty-state/empty_balance.svg"
                    alt="empty_balance"
                  />
                  <img
                    v-else
                    src="/images/empty-state/unauthorized_balance.svg"
                    alt="unauthorized_balance"
                  />
                </div>
              </template>
              <template #title>
                <div :class="{ 'balances-unauthorized-title': !authorized }">
                  {{
                    authorized
                      ? t('accountView.balances.notFound.title')
                      : t('accountView.balances.unauthorized.title')
                  }}
                </div>
              </template>
              <template #description>
                <div
                  class="balances-empty-description"
                  :class="{ 'balances-unauthorized-description': !authorized }"
                >
                  {{
                    authorized
                      ? t('accountView.balances.notFound.subtitle')
                      : t('accountView.balances.unauthorized.subtitle')
                  }}
                </div>
              </template>
            </EmptyState>
          </template>
          <template #failed>
            <EmptyState>
              <template #image>
                <div class="balances-empty-icon">
                  <img
                    src="/images/empty-state/error_balance.svg"
                    alt="empty_balance"
                  />
                </div>
              </template>
              <template #title>
                {{ t('accountView.balances.error.title') }}
              </template>
              <template #description>
                <div class="balances-empty-description">
                  {{ t('accountView.balances.error.subtitle') }}
                </div>
              </template>
            </EmptyState>
          </template>
        </BalanceTable>
      </div>
    </div>

    <div class="warning-card" v-if="!authorized && !pending">
      <div class="warning-icon">
        <IconError class="icon" color="#a16207" />
      </div>
      <p>{{ t('accountView.visibilityWarning') }}</p>
    </div>

    <Tabs v-if="account?.address && !pending" class="account-tabs" :tabs="tabs">
      <template #tab-1-content>
        <TransactionsTable
          class="transactions-table"
          :search-params="transactionsSearchParams"
        >
          <template #not-found>
            <TransactionEmptyState />
          </template>
        </TransactionsTable>
      </template>
      <template #tab-2-content>
        <TransfersTable :address="account.address" />
      </template>
    </Tabs>
  </div>
</template>
<script lang="ts" setup>
import { computed, type PropType } from 'vue';
import { useI18n } from 'vue-i18n';

import IconError from './icons/IconError.vue';

import SearchForm from '@/components/SearchForm.vue';
import AccountTable from '@/components/account/InfoTable.vue';
import TransactionEmptyState from '@/components/account/TransactionEmptyState.vue';
import BalanceTable from '@/components/balances/Table.vue';
import Breadcrumbs from '@/components/common/Breadcrumbs.vue';
import EmptyState from '@/components/common/EmptyState.vue';
import Spinner from '@/components/common/Spinner.vue';
import Tabs from '@/components/common/Tabs.vue';
import Title from '@/components/common/Title.vue';
import TransactionsTable from '@/components/transactions/Table.vue';
import TransfersTable from '@/components/transfers/Table.vue';

import type { BreadcrumbItem } from '@/components/common/Breadcrumbs.vue';
import type { Account } from '@/composables/useAddress';

import { shortValue } from '@/utils/formatters';

const props = defineProps({
  account: {
    type: [Object, null] as PropType<Account | null>,
    required: true,
    default: null,
  },
  pending: {
    type: Boolean,
    default: false,
  },
  failed: {
    type: Boolean,
    default: false,
  },
  authorized: {
    type: Boolean,
    default: true,
  },
});

const { t } = useI18n();

const tabs = computed(() => [
  { title: t('tabs.transactions'), hash: '#transactions' },
  { title: t('tabs.transfers'), hash: '#transfers' },
]);
const breadcrumbItems = computed((): BreadcrumbItem[] | [] => {
  if (props.account?.address) {
    return [
      { to: { name: 'home' }, text: t('breadcrumbs.home') },
      {
        text: `${t('accountView.accountNumber')}${shortValue(props.account?.address)}`,
      },
    ];
  }
  return [];
});

const transactionsSearchParams = computed(() => ({
  address: props.account?.address,
}));
</script>

<style lang="scss">
.head-block {
  @apply mb-8 flex flex-col-reverse justify-between lg:mb-10 lg:flex-row;
  h1 {
    @apply mt-3;
  }
  .search-form {
    @apply mb-6 w-full max-w-[26rem] lg:mb-0;
  }
}
.tables-container {
  @apply mt-8 grid grid-cols-1 gap-4;
  .account-tables-container {
    @apply grid grid-cols-1 gap-4 lg:grid-cols-2;
  }
  h2 {
    @apply mb-4;
  }
  .table-transaction-title {
    @apply text-gray-800;
  }
  .account-table {
    @apply mb-8;
  }
  .balance-table {
    @apply mb-4 overflow-hidden bg-white;
    .balances-empty-icon {
      @apply m-auto;
      img {
        @apply w-[2.875rem];
      }
    }
    .balances-empty-description {
      @apply max-w-[16rem] whitespace-normal;
    }
    .balances-unauthorized-title {
      @apply text-error-700 font-bold;
    }
    .balances-unauthorized-description {
      @apply text-error-500 max-w-[24rem];
    }
  }
  .transactions-table {
    @apply shadow-md;
  }
}
.transaction-table-error {
  @apply text-2xl text-error-700;
}
</style>

<style lang="scss">
.account-tabs {
  .transactions-table {
    .table-body {
      @apply rounded-t-none;
    }
    table thead tr th {
      @apply first:rounded-none last:rounded-none;
    }
  }
}

.warning-card {
  @apply flex items-center gap-3 rounded-lg bg-warning-50 p-4 text-warning-700;

  .warning-icon {
    @apply flex-shrink-0;

    .icon {
      @apply h-5 w-5;
    }
  }

  p {
    @apply text-sm;
  }
}
</style>
